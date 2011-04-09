//
//  PlaceDataCenter.m
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceDataCenter.h"
#import "Place.h"
#import "Place+Serialize.h"

static PlaceDataCenter *_defaultCenter = nil;
static NSMutableDictionary *_pkDict = nil;

@implementation PlaceDataCenter

#pragma mark -
#pragma mark Shared Instance
+ (id)defaultCenter {
  @synchronized(self) {
    if (_defaultCenter == nil) {
      _defaultCenter = [[self alloc] init];
    }
    return _defaultCenter;
  }
}

+ (void)initialize {
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  _pkDict = [[NSMutableDictionary dictionary] retain];
  
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getPlaces" substitutionVariables:[NSDictionary dictionary]];
  
  // Execute the fetch
  NSError *error = nil;
  NSArray *foundPlaces = [context executeFetchRequest:fetchRequest error:&error];
  
  for (Place *place in foundPlaces) {
    [_pkDict setValue:[place objectID] forKey:place.id];
  }
}

- (id)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
  }
  return self;
}

- (void)coreDataDidReset {
  RELEASE_SAFELY(_pkDict);
  _pkDict = [[NSMutableDictionary dictionary] retain];
}

- (void)getPlaces {
  NSURL *placesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/me/places", KUPO_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Since
  NSDate *lastFetched = [[NSUserDefaults standardUserDefaults] valueForKey:@"placesSince"];
  [params setValue:[NSString stringWithFormat:@"%0.0f", [lastFetched timeIntervalSince1970]] forKey:@"since"];
  
  [self sendOperationWithURL:placesUrl andMethod:GET andHeaders:nil andParams:params];
}

- (void)loadMorePlaces {
  NSURL *placesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/me/places", KUPO_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Since
  NSDate *lastFetched = [[NSUserDefaults standardUserDefaults] valueForKey:@"placesUntil"];
  [params setValue:[NSString stringWithFormat:@"%0.0f", [lastFetched timeIntervalSince1970]] forKey:@"until"];
  
  [self sendOperationWithURL:placesUrl andMethod:GET andHeaders:nil andParams:params];
}

#pragma mark Fixtures
- (void)loadPlacesFromFixture {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"places" ofType:@"json"];
  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
  NSDictionary *fixtureDict = [fixtureData JSONValue];
  [self serializePlacesWithDictionary:fixtureDict];
  
  [super dataCenterFinishedWithOperation:nil];
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [self serializePlacesWithDictionary:_response];
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFailedWithOperation:operation];
}

#pragma mark Serialize Response
- (void)serializePlacesWithDictionary:(NSDictionary *)dictionary {
  // Core Data Serialize
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  
  // Read placesSince and placesUntil
  NSDate *placesSince = [[NSUserDefaults standardUserDefaults] valueForKey:@"placesSince"];
  NSDate *placesUntil = [[NSUserDefaults standardUserDefaults] valueForKey:@"placesUntil"];
  
  Place *currentPlace = nil;
  
  // Insert into Core Data
  for (NSDictionary *placeDict in [dictionary valueForKey:@"values"]) {
    
    // Check for dupes
    NSManagedObjectID *existingId = [_pkDict objectForKey:[placeDict objectForKey:@"id"]];
    if (existingId) {
      // Existing Found
      Place *existingPlace = (Place *)[context objectWithID:existingId];
      DLog(@"existing place found with id: %@", [placeDict valueForKey:@"id"]);
      currentPlace = [existingPlace updatePlaceWithDictionary:placeDict];
    } else {
      currentPlace = [Place addPlaceWithDictionary:placeDict inContext:context];
    }
    
    // Update since/until
    if ([currentPlace.timestamp isEqualToDate:[currentPlace.timestamp laterDate:placesSince]]) {
      placesSince = currentPlace.timestamp;
    }
    
    if ([currentPlace.timestamp isEqualToDate:[currentPlace.timestamp earlierDate:placesUntil]]) {
      placesUntil = currentPlace.timestamp;
    }
  }
  
  [context obtainPermanentIDsForObjects:[[context insertedObjects] allObjects] error:nil];
  for (Place *newPlace in [context insertedObjects]) {
    [_pkDict setValue:[newPlace objectID] forKey:newPlace.id];
  }
  
  [[NSUserDefaults standardUserDefaults] setValue:placesSince forKey:@"placesSince"];
  [[NSUserDefaults standardUserDefaults] setValue:placesUntil forKey:@"placesUntil"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  // Save to Core Data
  NSError *error = nil;
  if ([context hasChanges]) {
    if (![context save:&error]) {
      // CoreData ERROR!
      abort(); // NOTE: DO NOT SHIP
    }
  }
}

#pragma mark Fetch Requests
- (NSFetchRequest *)getPlacesFetchRequest {
  NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO selector:@selector(compare:)];
  NSArray * sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
  [sortDescriptor release];
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getPlaces" substitutionVariables:[NSDictionary dictionary]];
  [fetchRequest setSortDescriptors:sortDescriptors];
//  [fetchRequest setFetchLimit:limit];
  return fetchRequest;
}

@end

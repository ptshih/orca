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

@implementation PlaceDataCenter

@synthesize context = _context;

#pragma mark -
#pragma mark Shared Instance
+ (id)defaultCenter {
  @synchronized(self) {
    if (_defaultCenter == nil) {
      _defaultCenter = [[self alloc] init];
      _defaultCenter.context = [LICoreDataStack newManagedObjectContext];
    }
    return _defaultCenter;
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
}

- (void)getPlacesWithSince:(NSDate *)sinceDate {
  NSURL *placesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/me/places", KUPO_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Since
  NSTimeInterval since = [sinceDate timeIntervalSince1970] - SINCE_SAFETY_NET;
  [params setValue:[NSString stringWithFormat:@"%0.0f", since] forKey:@"since"];
  
  [self sendOperationWithURL:placesUrl andMethod:GET andHeaders:nil andParams:params];
}

- (void)loadMorePlacesWithUntil:(NSDate *)untilDate {
  NSURL *placesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/me/places", KUPO_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Until
  [params setValue:[NSString stringWithFormat:@"%0.0f", [untilDate timeIntervalSince1970]] forKey:@"until"];
  
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
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
  
  NSArray *sortedPlaces = [[dictionary valueForKey:@"values"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSMutableArray *sortedPlaceIds = [NSMutableArray array];
  for (NSDictionary *placeDict in sortedPlaces) {
    [sortedPlaceIds addObject:[placeDict valueForKey:@"id"]];
  }
    
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedPlaceIds]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease]]];
  
  
  NSError *error = nil;
  NSArray *foundPlaces = [self.context executeFetchRequest:fetchRequest error:&error];
  
  int i = 0;
  for (NSDictionary *placeDict in sortedPlaces) {
    if ([foundPlaces count] > 0 && [[placeDict valueForKey:@"id"] isEqualToString:[[foundPlaces objectAtIndex:i] id]]) {
      DLog(@"found duplicated place with id: %@", [[foundPlaces objectAtIndex:i] id]);
      [[foundPlaces objectAtIndex:i] updatePlaceWithDictionary:placeDict];
    } else {
      // Insert
      [Place addPlaceWithDictionary:placeDict inContext:self.context];
    }
    i++;
  }
  
  // Save to Core Data
  if ([self.context hasChanges]) {
    if (![self.context save:&error]) {
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

- (void)dealloc {
  RELEASE_SAFELY(_context);
  [super dealloc];
}

@end

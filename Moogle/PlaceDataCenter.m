//
//  PlaceDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceDataCenter.h"
#import "Place.h"
#import "Place+Serialize.h"

static NSMutableDictionary *_pkDict = nil;

@implementation PlaceDataCenter

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

- (void)getPlaces {
  NSURL *placesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/me/places", MOOGLE_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
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

#pragma mark MoogleDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [self serializePlacesWithDictionary:_response];
  [super dataCenterFinishedWithOperation:operation];
}

#pragma mark Serialize Response
- (void)serializePlacesWithDictionary:(NSDictionary *)dictionary {
  // Core Data Serialize
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  
  // Insert into Core Data
  for (NSDictionary *placeDict in [dictionary valueForKey:@"values"]) {
    // Check for dupes
    NSManagedObjectID *existingId = [_pkDict objectForKey:[placeDict objectForKey:@"id"]];
    if (existingId) {
      // Existing Found
      Place *existingPlace = (Place *)[context objectWithID:existingId];
      DLog(@"existing place found with id: %@", [placeDict valueForKey:@"id"]);
      [existingPlace updatePlaceWithDictionary:placeDict];
    } else {
      [Place addPlaceWithDictionary:placeDict inContext:context];
    }
  }
  
  [context obtainPermanentIDsForObjects:[[context insertedObjects] allObjects] error:nil];
  for (Place *newPlace in [context insertedObjects]) {
    [_pkDict setValue:[newPlace objectID] forKey:newPlace.id];
  }
  
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
  return fetchRequest;
}

@end

//
//  PodDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PodDataCenter.h"
#import "Pod.h"
#import "Pod+Serialize.h"

static NSMutableDictionary *_pkDict = nil;

@implementation PodDataCenter

+ (void)initialize {
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  _pkDict = [[NSMutableDictionary dictionary] retain];
  
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getPods" substitutionVariables:[NSDictionary dictionary]];
  
  // Execute the fetch
  NSError *error = nil;
  NSArray *foundPods = [context executeFetchRequest:fetchRequest error:&error];
  
  for (Pod *pod in foundPods) {
    [_pkDict setValue:[pod objectID] forKey:[pod.id stringValue]];
  }
}

#pragma mark Fixtures
- (void)loadPodsFromFixture {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pods" ofType:@"json"];
  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
  NSDictionary *fixtureDict = [fixtureData JSONValue];
  [self serializePodsWithDictionary:fixtureDict];
  
  [super dataCenterFinishedWithOperation:nil];
}

#pragma mark MoogleDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [self serializePodsWithDictionary:_response];
  [super dataCenterFinishedWithOperation:operation];
}

#pragma mark Serialize Response
- (void)serializePodsWithDictionary:(NSDictionary *)dictionary {
  // Core Data Serialize
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  
  // Insert into Core Data
  for (NSDictionary *podDict in [dictionary valueForKey:@"values"]) {
    // Check for dupes
    NSManagedObjectID *existingId = [_pkDict objectForKey:[[podDict objectForKey:@"id"] stringValue]];
    if (existingId) {
      // Existing Found
      Pod *existingPod = (Pod *)[context objectWithID:existingId];
      DLog(@"existing pod found with id: %@", [podDict valueForKey:@"id"]);
      [existingPod updatePodWithDictionary:podDict];
    } else {
      [Pod addPodWithDictionary:podDict inContext:context];
    }
  }
  
  [context obtainPermanentIDsForObjects:[[context insertedObjects] allObjects] error:nil];
  for (Pod *newPod in [context insertedObjects]) {
    [_pkDict setValue:[newPod objectID] forKey:[newPod.id stringValue]];
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
- (NSFetchRequest *)getPodsFetchRequest {
  NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO selector:@selector(compare:)];
  NSArray * sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
  [sortDescriptor release];
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getPods" substitutionVariables:[NSDictionary dictionary]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  return fetchRequest;
}

@end

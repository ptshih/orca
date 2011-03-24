//
//  FeedDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedDataCenter.h"
#import "Feed.h"
#import "Feed+Serialize.h"

@implementation FeedDataCenter

#pragma mark Fixtures
- (void)loadFeedsFromFixture {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"feeds" ofType:@"json"];
  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
  NSDictionary *fixtureDict = [fixtureData JSONValue];
  [self serializeFeedsWithDictionary:fixtureDict];
  
  [super dataCenterFinishedWithOperation:nil];
}

#pragma mark MoogleDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [self serializeFeedsWithDictionary:_response];
  [super dataCenterFinishedWithOperation:operation];
}

#pragma mark Serialize Response
- (void)serializeFeedsWithDictionary:(NSDictionary *)dictionary {
  // Core Data Serialize
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  
  // Fetch and Unique the IDs
  // MUST IMPLEMENT
  
  // Insert into Core Data
  for (NSDictionary *feedDict in [dictionary objectForKey:@"values"]) {
    [Feed addFeedWithDictionary:feedDict inContext:context];
  }
  
  // Save to Core Data
  if ([context hasChanges]) {
    if (![context save:nil]) {
      // CoreData ERROR!
      abort(); // NOTE: DO NOT SHIP
    }
  }
}

#pragma mark FetchRequests
- (NSFetchRequest *)getFeedsFetchRequestForPod:(NSNumber *)podId {
  NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO selector:@selector(compare:)];
  NSArray * sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
  [sortDescriptor release];
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getFeedsForPod" substitutionVariables:[NSDictionary dictionaryWithObject:podId forKey:@"desiredPodId"]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  return fetchRequest;
}

@end

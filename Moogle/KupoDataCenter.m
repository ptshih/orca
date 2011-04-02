//
//  KupoDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoDataCenter.h"
#import "Kupo.h"
#import "Kupo+Serialize.h"

static NSMutableDictionary *_pkDict = nil;

@implementation KupoDataCenter

+ (void)initialize {
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  _pkDict = [[NSMutableDictionary dictionary] retain];
  
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getKupos" substitutionVariables:[NSDictionary dictionary]];
  
  // Execute the fetch
  NSError *error = nil;
  NSArray *foundKupos = [context executeFetchRequest:fetchRequest error:&error];
  
  for (Kupo *kupo in foundKupos) {
    [_pkDict setValue:[kupo objectID] forKey:kupo.id];
  }
}

- (void)getKuposForPlaceWithPlaceId:(NSString *)placeId {
  NSURL *KuposUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/places/%@/kupos", MOOGLE_BASE_URL, placeId]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [self sendOperationWithURL:KuposUrl andMethod:GET andHeaders:nil andParams:params];
}

#pragma mark Fixtures
- (void)loadKuposFromFixture {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"kupos" ofType:@"json"];
  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
  NSDictionary *fixtureDict = [fixtureData JSONValue];
  [self serializeKuposWithDictionary:fixtureDict];
  
  [super dataCenterFinishedWithOperation:nil];
}

#pragma mark MoogleDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [self serializeKuposWithDictionary:_response];
  [super dataCenterFinishedWithOperation:operation];
}

#pragma mark Serialize Response
- (void)serializeKuposWithDictionary:(NSDictionary *)dictionary {
  // Core Data Serialize
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  
  // Fetch and Unique the IDs
  // MUST IMPLEMENT
  
  // Insert into Core Data
  for (NSDictionary *kupoDict in [dictionary objectForKey:@"values"]) {
    // Check for dupes
    NSManagedObjectID *existingId = [_pkDict objectForKey:[kupoDict objectForKey:@"id"]];
    if (!existingId) {
      [Kupo addKupoWithDictionary:kupoDict inContext:context];
    }
  }
  
  [context obtainPermanentIDsForObjects:[[context insertedObjects] allObjects] error:nil];
  for (Kupo *newKupo in [context insertedObjects]) {
    [_pkDict setValue:[newKupo objectID] forKey:newKupo.id];
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

#pragma mark FetchRequests
- (NSFetchRequest *)moogleFrame:(NSString *)placeId {
  NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO selector:@selector(compare:)];
  NSArray * sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
  [sortDescriptor release];
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getKuposForPlace" substitutionVariables:[NSDictionary dictionaryWithObject:placeId forKey:@"desiredPlaceId"]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  return fetchRequest;
}

@end

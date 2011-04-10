//
//  KupoDataCenter.m
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoDataCenter.h"
#import "Kupo.h"
#import "Kupo+Serialize.h"

static KupoDataCenter *_defaultCenter = nil;
static NSMutableDictionary *_pkDict = nil;

@implementation KupoDataCenter

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
  NSManagedObjectContext *context = [LICoreDataStack sharedManagedObjectContext];
  _pkDict = [[NSMutableDictionary dictionary] retain];
  
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getKupos" substitutionVariables:[NSDictionary dictionary]];
  
  // Execute the fetch
  NSError *error = nil;
  NSArray *foundKupos = [context executeFetchRequest:fetchRequest error:&error];
  
  for (Kupo *kupo in foundKupos) {
    [_pkDict setValue:[kupo objectID] forKey:kupo.id];
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

- (void)getKuposForPlaceWithPlaceId:(NSString *)placeId andSince:(NSDate *)sinceDate {
  NSURL *kuposUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/places/%@/kupos", KUPO_BASE_URL, placeId]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Since
  NSTimeInterval since = [sinceDate timeIntervalSince1970] - SINCE_SAFETY_NET;
  [params setValue:[NSString stringWithFormat:@"%0.0f", since] forKey:@"since"];
  
  [self sendOperationWithURL:kuposUrl andMethod:GET andHeaders:nil andParams:params];
}

- (void)loadMoreKuposForPlaceWithPlaceId:(NSString *)placeId andUntil:(NSDate *)untilDate {
  NSURL *kuposUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/places/%@/kupos", KUPO_BASE_URL, placeId]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  // Until
  [params setValue:[NSString stringWithFormat:@"%0.0f", [untilDate timeIntervalSince1970]] forKey:@"until"];
  
  [self sendOperationWithURL:kuposUrl andMethod:GET andHeaders:nil andParams:params];
}

#pragma mark Fixtures
- (void)loadKuposFromFixture {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"kupos" ofType:@"json"];
  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
  NSDictionary *fixtureDict = [fixtureData JSONValue];
  [self serializeKuposWithDictionary:fixtureDict];
  
  [super dataCenterFinishedWithOperation:nil];
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [self serializeKuposWithDictionary:_response];
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFailedWithOperation:operation];
}

#pragma mark Serialize Response
- (void)serializeKuposWithDictionary:(NSDictionary *)dictionary {
  // Core Data Serialize
  NSManagedObjectContext *context = [LICoreDataStack sharedManagedObjectContext];
  
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
- (NSFetchRequest *)getKuposFetchRequestWithPlaceId:(NSString *)placeId {
  NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO selector:@selector(compare:)];
  NSArray * sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
  [sortDescriptor release];
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getKuposForPlace" substitutionVariables:[NSDictionary dictionaryWithObject:placeId forKey:@"desiredPlaceId"]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  return fetchRequest;
}

@end

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

@implementation KupoDataCenter

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
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
  
  NSArray *sortedKupos = [[dictionary valueForKey:@"values"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSMutableArray *sortedKupoIds = [NSMutableArray array];
  for (NSDictionary *kupoDict in sortedKupos) {
    [sortedKupoIds addObject:[kupoDict valueForKey:@"id"]];
  }
  
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Kupo" inManagedObjectContext:self.context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedKupoIds]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease]]];
  
  NSError *error = nil;
  NSArray *foundKupos = [self.context executeFetchRequest:fetchRequest error:&error];
  
  int i = 0;
  for (NSDictionary *kupoDict in sortedKupos) {
    if ([foundKupos count] > 0 && i < [foundKupos count] && [[kupoDict valueForKey:@"id"] isEqualToString:[[foundKupos objectAtIndex:i] id]]) {
      DLog(@"found duplicated kupo with id: %@", [[foundKupos objectAtIndex:i] id]);
    } else {
      // Insert
      [Kupo addKupoWithDictionary:kupoDict inContext:self.context];
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

#pragma mark FetchRequests
- (NSFetchRequest *)getKuposFetchRequestWithPlaceId:(NSString *)placeId {
  NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO selector:@selector(compare:)];
  NSArray * sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
  [sortDescriptor release];
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getKuposForPlace" substitutionVariables:[NSDictionary dictionaryWithObject:placeId forKey:@"desiredPlaceId"]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  return fetchRequest;
}

- (void)dealloc {
  RELEASE_SAFELY(_context);
  [super dealloc];
}

@end

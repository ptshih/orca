
//
//  PodDataCenter.m
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PodDataCenter.h"
#import "Pod.h"
#import "Pod+Serialize.h"

static dispatch_queue_t _coreDataSerializationQueue = nil;

@implementation PodDataCenter

+ (void)initialize {
  _coreDataSerializationQueue = dispatch_queue_create("com.sevenminutelabs.podCoreDataSerializationQueue", NULL);
}

+ (PodDataCenter *)defaultCenter {
  static PodDataCenter *defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

#pragma mark -
#pragma mark Prepare Request
- (void)getPods {
  NSURL *podsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pods", API_BASE_URL]];
  [self sendRequestWithURL:podsURL andMethod:GET andHeaders:nil andParams:nil andUserInfo:nil];
}

- (void)getPodsFromFixtures {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pods" ofType:@"json"];
  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
  
  // Process the batched results using GCD  
  dispatch_async(_coreDataSerializationQueue, ^{
    NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
    
    id response = [[fixtureData JSONValue] valueForKey:@"data"];
    
    // Process the Response for Pods
    if ([response isKindOfClass:[NSArray class]]) {
      [self serializePodsWithArray:response inContext:context];
    }
    
    // Save to CoreData
    [PSCoreDataStack saveInContext:context];
    
    // Release context
    [context release];
    
    dispatch_async(dispatch_get_main_queue(), ^{
      // Inform Delegate if all responses are parsed
      if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFinish:withResponse:)]) {
        [_delegate performSelector:@selector(dataCenterDidFinish:withResponse:) withObject:nil withObject:nil];
      }
    });
  });
}

#pragma mark -
#pragma mark Serialization
- (void)serializePodsWithRequest:(ASIHTTPRequest *)request {
  NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
  
  // Parse the JSON
  id response = [[[request responseData] JSONValue] valueForKey:@"data"];
  
  // Process the Response for Pods
  if ([response isKindOfClass:[NSArray class]]) {
    [self serializePodsWithArray:response inContext:context];
  }
  
  // Save to CoreData
  [PSCoreDataStack saveInContext:context];
  
  // Release context
  [context release];
}

#pragma mark Core Data Serialization
- (void)serializePodsWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context {
  NSString *uniqueKey = @"id";
  NSString *entityName = @"Pod";
  
  // Find all existing Pods
  NSArray *newUniqueKeyArray = [array valueForKey:uniqueKey];
  NSFetchRequest *existingFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [existingFetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
  [existingFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%K IN %@)", uniqueKey, newUniqueKeyArray]];
  [existingFetchRequest setPropertiesToFetch:[NSArray arrayWithObject:uniqueKey]];
  
  NSError *error = nil;
  NSArray *foundEntities = [context executeFetchRequest:existingFetchRequest error:&error];
  
  // Create a dictionary of existing pods
  NSMutableDictionary *existingEntities = [NSMutableDictionary dictionary];
  for (id foundEntity in foundEntities) {
    [existingEntities setObject:foundEntity forKey:[foundEntity valueForKey:uniqueKey]];
  }
  
  Pod *existingEntity = nil;
  for (NSDictionary *newEntity in array) {
    NSString *key = [newEntity valueForKey:uniqueKey];
    existingEntity = [existingEntities objectForKey:key];
    if (existingEntity) {
      // update
      [existingEntity updatePodWithDictionary:newEntity];
    } else {
      // insert
      [Pod addPodWithDictionary:newEntity inContext:context];
    }
  }
}

#pragma mark - Update Pod / Compose
- (void)updatePod:(Pod *)pod withUserInfo:(NSDictionary *)userInfo {
  // Userinfo has 3 keys (all strings)
  // message, podId, sequence
  
  pod.fromId = [userInfo objectForKey:@"fromId"];
  pod.fromName = [userInfo objectForKey:@"fromName"];
  pod.fromPictureUrl = [userInfo objectForKey:@"fromPictureUrl"];
  pod.sequence = [userInfo objectForKey:@"sequence"];
  pod.message = [userInfo objectForKey:@"message"];
  pod.timestamp = [NSDate dateWithTimeIntervalSince1970:[[userInfo objectForKey:@"timestamp"] longLongValue]];
  
  // Save to CoreData
  [PSCoreDataStack saveInContext:[pod managedObjectContext]];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  // Process the batched results using GCD  
  dispatch_async(_coreDataSerializationQueue, ^{
    [self serializePodsWithRequest:request];
    dispatch_async(dispatch_get_main_queue(), ^{
      // Inform Delegate if all responses are parsed
      if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFinish:withResponse:)]) {
        [_delegate performSelector:@selector(dataCenterDidFinish:withResponse:) withObject:request withObject:nil];
      }
    });
  });
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFail:withError:)]) {
    [_delegate performSelector:@selector(dataCenterDidFail:withError:) withObject:request withObject:[request error]];
  } 
}

- (void)dealloc {
  [super dealloc];
}

@end

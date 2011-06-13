
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

@implementation PodDataCenter

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
  NSURL *podsURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_BASE_URL, PODS_ENDPOINT]];
  [self sendRequestWithURL:podsURL andMethod:GET andHeaders:nil andParams:nil andUserInfo:nil];
}

- (void)getPodsFromFixtures {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"pods" ofType:@"json"];
  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
  
  // Process the batched results in a BG thread
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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
  // Traverse response array and serialize dictionary -> coredata
  NSString *sortKey = @"id";
  NSString *entityName = @"Pod";
  
  NSArray *sortedDicts = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES]]];
  NSArray *sortedKeys = [sortedDicts valueForKey:sortKey];
  
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedKeys]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:YES]]];
    
  
  NSError *error = nil;
  NSArray *foundEntities = [context executeFetchRequest:fetchRequest error:&error];
  
  Pod *pod = nil;
  int i = 0;
  for (NSDictionary *entityDict in sortedDicts) {
    // Create a local autorelease pool
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSString *key = [entityDict valueForKey:sortKey];
    if ([foundEntities count] > 0 && i < [foundEntities count] && [key isEqualToString:[[foundEntities objectAtIndex:i] id]]) {
      // Duplicate entity found
      pod = [foundEntities objectAtIndex:i];
      [pod updatePodWithDictionary:entityDict];
      i++;
    } else {
      // No duplicate found
      [Pod addPodWithDictionary:entityDict inContext:context];
    }

    [pool drain];
  }
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  // Process the batched results in a BG thread
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
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

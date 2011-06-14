//
//  MessageDataCenter.m
//  Orca
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageDataCenter.h"
#import "Message.h"
#import "Message+Serialize.h"

@implementation MessageDataCenter

+ (MessageDataCenter *)defaultCenter {
  static MessageDataCenter *defaultCenter = nil;
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
- (void)getMessagesForPodId:(NSString *)podId {
  NSURL *messagesURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pods/%@/messages", API_BASE_URL, podId]];
  [self sendRequestWithURL:messagesURL andMethod:GET andHeaders:nil andParams:nil andUserInfo:nil];
}

- (void)getMessagesFromFixtures {
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"messages" ofType:@"json"];
  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
  
  // Process the batched results in a BG thread
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
    
    id response = [[fixtureData JSONValue] valueForKey:@"data"];
    
    // Process the Response for Pods
    if ([response isKindOfClass:[NSArray class]]) {
      [self serializeMessagesWithArray:response inContext:context];
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
- (void)serializeMessagesWithRequest:(ASIHTTPRequest *)request {
  NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
  
  // Parse the JSON
  id response = [[[request responseData] JSONValue] valueForKey:@"data"];
  
  // Process the Response for Messages
  if ([response isKindOfClass:[NSArray class]]) {
    [self serializeMessagesWithArray:response inContext:context];
  }
  
  // Save to CoreData
  [PSCoreDataStack saveInContext:context];
  
  // Release context
  [context release];
}


#pragma mark Core Data Serialization
- (void)serializeMessagesWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context {
  NSString *uniqueKey = @"sequence";
  NSString *entityName = @"Message";
  
  NSArray *newUniqueKeyArray = [array valueForKey:uniqueKey];
  
  // Find all existing Messages
  NSFetchRequest *existingFetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [existingFetchRequest setEntity:[NSEntityDescription entityForName:entityName inManagedObjectContext:context]];
  [existingFetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(%K IN %@)", uniqueKey, newUniqueKeyArray]];
  [existingFetchRequest setPropertiesToFetch:[NSArray arrayWithObject:uniqueKey]];
  
  NSError *error = nil;
  NSArray *foundEntities = [context executeFetchRequest:existingFetchRequest error:&error];
  
  // Create a dictionary of existing messages
  NSMutableDictionary *existingEntities = [NSMutableDictionary dictionary];
  for (id foundEntity in foundEntities) {
    [existingEntities setObject:foundEntity forKey:[foundEntity valueForKey:uniqueKey]];
  }
  
  Message *existingEntity = nil;
  for (NSDictionary *newEntity in array) {
    NSString *key = [newEntity valueForKey:uniqueKey];
    existingEntity = [existingEntities objectForKey:key];
    if (existingEntity) {
      // update
      [existingEntity updateMessageWithDictionary:newEntity];
    } else {
      // insert
      [Message addMessageWithDictionary:newEntity inContext:context];
    }
  }
}

- (void)serializeComposedMessageWithUserInfo:(NSDictionary *)userInfo {
  // Userinfo has 3 keys (all strings)
  // message, podId, sequence
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];

    [Message addMessageWithDictionary:userInfo inContext:context];
    
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
#pragma mark PSDataCenterDelegate
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  // Process the batched results in a BG thread
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self serializeMessagesWithRequest:request];
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

@end

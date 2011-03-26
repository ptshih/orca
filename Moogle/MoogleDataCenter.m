//
//  MoogleDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleDataCenter.h"

@interface MoogleDataCenter (Private)

- (BOOL)serializeResponse:(NSData *)responseData;
- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary forKeys:(NSArray *)keys;
- (NSArray *)sanitizeArray:(NSArray *)array;

@end

@implementation MoogleDataCenter

@synthesize delegate = _delegate;
@synthesize response = _response;
@synthesize rawResponse = _rawResponse;
@synthesize op = _op;

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (NSArray *)sanitizeArray:(NSArray *)array {
  NSMutableArray *sanitizedArray = [NSMutableArray array];
  
  // Loop thru all dictionaries in the array
  NSDictionary *sanitizedDictionary = nil;
  for (NSDictionary *dictionary in array) {
    sanitizedDictionary = [self sanitizeDictionary:dictionary forKeys:[dictionary allKeys]];
    [sanitizedArray addObject:sanitizedDictionary];
  }

  return sanitizedArray;
}
     
- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary forKeys:(NSArray *)keys {
 NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionary];
 
 // Loop thru all keys we expect to get and remove any keys with nil values
 NSString *value = nil;
 for (NSString *key in keys) {
   value = [dictionary valueForKey:key];
   
   if ([value notNil]) {
     [sanitizedDictionary setValue:value forKey:key];
   }
 }
 
 return sanitizedDictionary;
}

- (BOOL)serializeResponse:(NSData *)responseData {
  // Serialize the response
  if (_response) {
    [_response release];
    _response = nil;
  }
  if (_rawResponse) {
    [_rawResponse release];
    _rawResponse = nil;
  }
  
  _rawResponse = [[responseData JSONValue] retain];
//  _rawResponse = [[responseData objectFromJSONData] retain];
  
  // We should sanitize the response
  if ([_rawResponse isKindOfClass:[NSArray class]]) {
    _response = [[self sanitizeArray:_rawResponse] retain];
  } else if ([_rawResponse isKindOfClass:[NSDictionary class]]) {
    _response = [[self sanitizeDictionary:_rawResponse forKeys:[_rawResponse allKeys]] retain];
  } else {
    // Throw an assertion, why is it not a dictionary or an array???
    DLog(@"### ERROR IN DATA CENTER, RESPONSE IS NEITHER AN ARRAY NOR A DICTIONARY");
  }
  
  if (self.response) {
    return YES;
  } else {
    return NO;
  }
}

#pragma mark Send Operation
- (void)sendOperationWithURL:(NSURL *)url andMethod:(NSString *)method andParams:(NSDictionary *)params {
  if (!_op) {
    _op = [[LINetworkOperation alloc] initWithURL:url];
    _op.delegate = self;
  }
  
  // Set op method (defaults to GET)
  _op.requestMethod = method ? method : GET;
  
  // Build Params if exists
  if (params) {
    NSArray *allKeys = [params allKeys];
    NSArray *allValues = [params allValues];
    for (int i = 0; i < [params count]; i++) {
      // NOTE: should probably type transform coerce in the future
      [_op addRequestParam:[allKeys objectAtIndex:i] value:[allValues objectAtIndex:i]];
    }
  }
  
  [[LINetworkQueue sharedQueue] addOperation:_op];
}

/**
 Network Operation Delegate Callbacks
 */
#pragma mark LINetworkOperationDelegate
- (void)networkOperationDidFinish:(LINetworkOperation *)operation {
  DLog(@"Callback: Operation finished: %@", operation);
  // This is on the main thread
  NSInteger statusCode = [operation responseStatusCode];
  if(statusCode >= 200 && statusCode < 400) {
    // Assume this is a successful response
    if ([self serializeResponse:[operation responseData]]) {
      [self dataCenterFinishedWithOperation:operation];
    } else {
      // Something is wrong with the response
      [self dataCenterFailedWithOperation:operation];
    }
  } else {
    // Assume this is a BAD response code
    [self dataCenterFailedWithOperation:operation];
  }
}

- (void)networkOperationDidFail:(LINetworkOperation *)operation {
  DLog(@"Callback: Operation failed: %@", operation);
  // Just fail it for now
  [self dataCenterFailedWithOperation:operation];
}

// UNUSED
- (void)networkOperationDidStart:(LINetworkOperation *)operation {
  DLog(@"Callback: Operation started: %@", operation);  
}

- (void)networkOperationDidTimeout:(LINetworkOperation *)operation {
  DLog(@"Callback: Operation timed out: %@", operation);
}

#pragma mark Delegate Callbacks
// Subclass should Implement
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {
  // By now the response should already be serialized into self.parsedResponse of type id
  
  // Inform delegate the operation Finished
  if (self.delegate) {
    [self.delegate retain];
    if ([self.delegate respondsToSelector:@selector(dataCenterDidFinish:)]) {
      [self.delegate performSelector:@selector(dataCenterDidFinish:) withObject:operation];
    }
    [self.delegate release];
  }
}

// Subclass should Implement (Optional)
- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  // Inform delegate the operation Failed
  if (self.delegate) {
    [self.delegate retain];
    if ([self.delegate respondsToSelector:@selector(dataCenterDidFail:)]) {
      [self.delegate performSelector:@selector(dataCenterDidFail:) withObject:operation];
    }
    [self.delegate release];
  }
}

- (void)dealloc {
  if (_op) [_op clearDelegatesAndCancel];
  RELEASE_SAFELY(_op);
  RELEASE_SAFELY (_response);
  RELEASE_SAFELY(_rawResponse);
  [super dealloc];
}

@end

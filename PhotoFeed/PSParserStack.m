//
//  PSParserStack.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSParserStack.h"
#import "JSON.h"

static NSThread *_parseThread = nil;
static PSParserStack *_sharedParser = nil;

@interface PSParserStack (Private)

- (void)parseDataInThread:(NSDictionary *)payload;

@end

@implementation PSParserStack

+ (void)initialize {
  if (self == [PSParserStack class]) {
    // Allocs for class (statics)
    _parseThread = [[NSThread alloc] initWithTarget:[self class] selector:@selector(parseThreadMain) object:nil];
    [_parseThread start];
  }
}

#pragma mark Shared Parser Instance
+ (PSParserStack *)sharedParser {
  if (!_sharedParser) {
    _sharedParser = [[self alloc] init];
  }
  return _sharedParser;
}

#pragma mark -
#pragma mark Thread
+ (void)parseThreadMain {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  //  NSLog(@"op thread main started on thread: %@", [NSThread currentThread]);
  [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
  [[NSRunLoop currentRunLoop] run];
  [pool release];
}

- (void)parseData:(NSData *)data withDelegate:(id)delegate andUserInfo:(NSDictionary *)userInfo {
  NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:data, @"data", delegate, @"delegate", userInfo, @"userInfo", nil];
  [self performSelector:@selector(parseDataInThread:) onThread:_parseThread withObject:payload waitUntilDone:NO];
}

- (void)parseDataInThread:(NSDictionary *)payload {
  NSData *data = [payload objectForKey:@"data"];
  id delegate = [payload objectForKey:@"delegate"];
  NSDictionary *userInfo = [payload objectForKey:@"userInfo"];
  id response = [data JSONValue];
  
  NSDictionary *responsePayload = [NSDictionary dictionaryWithObjectsAndKeys:response, @"response", delegate, @"delegate", userInfo, @"userInfo", nil];
  
  [self performSelectorOnMainThread:@selector(respondToDelegate:) withObject:responsePayload waitUntilDone:NO];
}

- (void)respondToDelegate:(NSDictionary *)payload {
  id response = [payload objectForKey:@"response"];
  id delegate = [payload objectForKey:@"delegate"];
  NSDictionary *userInfo = [payload objectForKey:@"userInfo"];
  if (delegate && [delegate respondsToSelector:@selector(parseFinishedWithResponse:andUserInfo:)]) {
    [delegate parseFinishedWithResponse:response andUserInfo:userInfo];
  }
}

@end

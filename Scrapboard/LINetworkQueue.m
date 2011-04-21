//
//  LINetworkQueue.m
//  NetworkStack
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import "LINetworkQueue.h"
#import "LINetworkOperation.h"

static LINetworkQueue *_sharedQueue = nil;

@implementation LINetworkQueue

- (id)init {
  self = [super init];
  if (self) {
    [self setMaxConcurrentOperationCount:4];
    [self setSuspended:NO];
  }
	return self;
}

- (void)cancelAllOperations {
  for (LINetworkOperation *op in [self operations]) {
    [op clearDelegatesAndCancel];
  }
}

+ (LINetworkQueue *)sharedQueue {
  @synchronized(self) {
    if (_sharedQueue == nil) {
      _sharedQueue = [[self alloc] init];
    }
    return _sharedQueue;
  }
}

+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (_sharedQueue == nil) {
      _sharedQueue = [super allocWithZone:zone];
      return _sharedQueue;
    }
  }
  return nil;
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)retain {
  return self;
}

- (NSUInteger)retainCount {
  return NSUIntegerMax;
}

- (void)release {
}

- (id)autorelease {
  return self;
}

@end

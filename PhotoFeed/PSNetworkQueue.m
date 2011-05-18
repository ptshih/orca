//
//  PSNetworkQueue.m
//  PSNetworkStack
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import "PSNetworkQueue.h"
#import "PSNetworkOperation.h"

static PSNetworkQueue *_sharedQueue = nil;

@implementation PSNetworkQueue

- (id)init {
  self = [super init];
  if (self) {
    [self setMaxConcurrentOperationCount:4];
    [self setSuspended:NO];
  }
	return self;
}

- (void)cancelAllOperations {
  for (PSNetworkOperation *op in [self operations]) {
    [op clearDelegatesAndCancel];
  }
}

+ (PSNetworkQueue *)sharedQueue {
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

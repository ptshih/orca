//
//  PSSearchStack.m
//  PhotoFeed
//
//  Created by Peter Shih on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSSearchStack.h"

static PSSearchStack *_sharedSearch = nil;

@implementation PSSearchStack

#pragma mark Shared Parser Instance
+ (PSSearchStack *)sharedSearch {
  if (!_sharedSearch) {
    _sharedSearch = [[self alloc] init];
  }
  return _sharedSearch;
}

- (id)init {
  self = [super init];
  if (self) {
    _searchQueue = [[NSOperationQueue alloc] init];
    [_searchQueue setMaxConcurrentOperationCount:1];
  }
  return self;
}

#pragma mark -
#pragma mark NSOperationQueue Actions
- (void)addOperation:(NSOperation *)op {
  [_searchQueue addOperation:op];
}

- (NSUInteger)opCount {
  return [_searchQueue operationCount];
}

@end

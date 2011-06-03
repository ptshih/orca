//
//  PSSearchStack.m
//  PhotoFeed
//
//  Created by Peter Shih on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSSearchStack.h"

@implementation PSSearchStack

#pragma mark Shared Parser Instance
+ (PSSearchStack *)sharedSearch {
  static PSSearchStack *sharedSearch = nil;
  if (!sharedSearch) {
    sharedSearch = [[self alloc] init];
  }
  return sharedSearch;
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

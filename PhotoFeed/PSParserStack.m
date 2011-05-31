//
//  PSParserStack.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSParserStack.h"

static PSParserStack *_sharedParser = nil;

@implementation PSParserStack

#pragma mark Shared Parser Instance
+ (PSParserStack *)sharedParser {
  if (!_sharedParser) {
    _sharedParser = [[self alloc] init];
  }
  return _sharedParser;
}

- (id)init {
  self = [super init];
  if (self) {
    _parserQueue = [[NSOperationQueue alloc] init];
    [_parserQueue setMaxConcurrentOperationCount:10];
  }
  return self;
}

#pragma mark -
#pragma mark NSOperationQueue Actions
- (void)addOperation:(NSOperation *)op {
  [_parserQueue addOperation:op];
}

@end

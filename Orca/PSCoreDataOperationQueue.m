//
//  PSCoreDataOperationQueue.m
//  Orca
//
//  Created by Peter Shih on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCoreDataOperationQueue.h"


@implementation PSCoreDataOperationQueue

+ (PSCoreDataOperationQueue *)sharedQueue {
  static PSCoreDataOperationQueue *sharedQueue;
  if (!sharedQueue) {
    sharedQueue = [[self alloc] init];
  }
  return sharedQueue;
}

- (id)init {
  self = [super init];
  if (self) {
    // Make sure this queue runs serially, 1 at a time
    [self setMaxConcurrentOperationCount:1];
    [self setSuspended:NO];
  }
  return self;
}

@end

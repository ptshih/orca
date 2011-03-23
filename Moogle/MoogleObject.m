//
//  MoogleObject.m
//  Moogle
//
//  Created by Peter Shih on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleObject.h"


@implementation MoogleObject

- (id)init {
  self = [super init];
  if (self) {
    DLog(@"Called by class: %@", [self class]);
  }
  return self;
}

- (void)dealloc {
  DLog(@"Called by class: %@", [self class]);
  [super dealloc];
}

@end

//
//  MoogleViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleViewController.h"


@implementation MoogleViewController

- (id)init {
  self = [super init];
  if (self) {
    DLog(@"Called by class: %@", [self class]);
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

@end

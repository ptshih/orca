//
//  ConfigDataCenter.m
//  Orca
//
//  Created by Peter Shih on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigDataCenter.h"


@implementation ConfigDataCenter

+ (ConfigDataCenter *)defaultCenter {
  static ConfigDataCenter *defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

@end

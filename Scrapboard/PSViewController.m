//
//  PSViewController.m
//  Scrapboard
//
//  Created by Peter Shih on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"

@implementation PSViewController

- (id)init {
  self = [super init];
  if (self) {
    DLog(@"Called by class: %@", [self class]);
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.opaque = YES;
  self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  self.view.autoresizesSubviews = YES;
}

- (void)dealloc {
  DLog(@"Called by class: %@", [self class]);
  [super dealloc];
}

@end

//
//  MoogleViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleViewController.h"

static UIImage *_backgroundImage = nil;

@implementation MoogleViewController

+ (void)initialize {
  _backgroundImage = [[UIImage imageNamed:@"bamboo_bg_alpha.png"] retain];
}

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
  self.view.backgroundColor = [UIColor colorWithPatternImage:_backgroundImage];
  self.view.frame = CGRectMake(0, 20, 320, 460);
  self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  self.view.autoresizesSubviews = YES;
}

- (void)dealloc {
  DLog(@"Called by class: %@", [self class]);
  [super dealloc];
}

@end

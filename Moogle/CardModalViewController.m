//
//  CardModalViewController.m
//  Moogle
//
//  Created by Peter Shih on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardModalViewController.h"

@implementation CardModalViewController

- (id)init {
  self = [super init];
  if (self) {
    _navigationBar = [[UINavigationBar alloc] init];
    _dismissButtonTitle = @"Cancel";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _navigationBar.frame = CGRectMake(0, 0, 320, 44);
  
  // Setup Nav Items and Done button
  _navItem = [[UINavigationItem alloc] initWithTitle:self.title];
  UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:_dismissButtonTitle style:UIBarButtonItemStyleBordered target:self action:@selector(dismiss)];
  _navItem.leftBarButtonItem = dismissButton;
  [dismissButton release];
  [_navigationBar setItems:[NSArray arrayWithObject:_navItem]];
  
  [self.view addSubview:_navigationBar];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
  RELEASE_SAFELY(_dismissButtonTitle);
  RELEASE_SAFELY(_navigationBar);
  RELEASE_SAFELY(_navItem);
  [super dealloc];
}

@end

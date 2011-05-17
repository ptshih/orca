//
//  CardModalViewController.m
//  OhSnap
//
//  Created by Peter Shih on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardModalViewController.h"

@implementation CardModalViewController

- (id)init {
  self = [super init];
  if (self) {
    _dismissButtonTitle = @"Cancel";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

}

- (void)showDismissButton {
  // Dismiss Button
  UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismiss)];
  self.navigationItem.leftBarButtonItem = dismissButton;
  [dismissButton release];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)dealloc {
  RELEASE_SAFELY(_dismissButtonTitle);
  [super dealloc];
}

@end

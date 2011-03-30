//
//  CardModalTableViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardModalTableViewController.h"

@implementation CardModalTableViewController

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
  UIButton *dismiss = [UIButton buttonWithType:UIButtonTypeCustom];
  dismiss.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  dismiss.frame = CGRectMake(0, 0, 60, 32);
  [dismiss setTitle:@"Cancel" forState:UIControlStateNormal];
  [dismiss setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
  dismiss.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
  UIImage *dismissImage = [[UIImage imageNamed:@"navigationbar_button_standard.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];  
  [dismiss setBackgroundImage:dismissImage forState:UIControlStateNormal];  
  [dismiss addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithCustomView:dismiss];
  
  self.navigationItem.leftBarButtonItem = dismissButton;
  [dismissButton release];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
  RELEASE_SAFELY(_dismissButtonTitle);
  [super dealloc];
}

@end

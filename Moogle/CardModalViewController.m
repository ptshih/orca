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
  _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
  
  // Setup Nav Items and Done button
  UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
  _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
  _navTitleLabel.textAlignment = UITextAlignmentCenter;
  _navTitleLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
  _navTitleLabel.font = [UIFont boldSystemFontOfSize:14.0];
  _navTitleLabel.numberOfLines = 3;
  _navTitleLabel.shadowColor = [UIColor blackColor];
  _navTitleLabel.shadowOffset = CGSizeMake(0, 1);
  _navTitleLabel.backgroundColor = [UIColor clearColor];
  [navTitleView addSubview:_navTitleLabel];
  
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
  
  _navItem = [[UINavigationItem alloc] initWithTitle:self.title];
  _navItem.leftBarButtonItem = dismissButton;
  _navItem.titleView = navTitleView;
  [navTitleView release];
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

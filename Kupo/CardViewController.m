//
//  CardViewController.m
//  Kupo
//
//  Created by Peter Shih on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardViewController.h"

static UIImage *_emptyImage = nil;

@interface CardViewController (Private)

- (void)showLoadingView;
- (void)hideLoadingView;

@end

@implementation CardViewController

+ (void)initialize {
  _emptyImage = [[UIImage imageNamed:@"empty.png"] retain];
}

- (id)init {
  self = [super init];
  if (self) {
    _activeScrollView = nil;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _emptyView = [[UIImageView alloc] initWithImage:_emptyImage];
  
  _emptyView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _emptyView.alpha = 1.0;
  _emptyView.hidden = YES;
  [self.view addSubview:_emptyView];
  
//  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];

  // Setup Nav Bar
  UIView *navTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
  _navTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 44)];
  _navTitleLabel.textAlignment = UITextAlignmentCenter;
  _navTitleLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
  _navTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
  _navTitleLabel.numberOfLines = 3;
  _navTitleLabel.shadowColor = [UIColor blackColor];
  _navTitleLabel.shadowOffset = CGSizeMake(0, 1);
  _navTitleLabel.backgroundColor = [UIColor clearColor];
  [navTitleView addSubview:_navTitleLabel];
  
  self.navigationItem.titleView = navTitleView;
  [navTitleView release];
  
  self.navigationController.navigationBar.tintColor = NAV_COLOR_DARK_BLUE;
  
//  self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-logo.png"]] autorelease];
}

- (void)back {
  [self.navigationController popViewControllerAnimated:YES];
}

// Optional Implementation
- (void)addBackButton {
//  UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
//  back.frame = CGRectMake(0, 0, 60, 32);
//  [back setTitle:@"Back" forState:UIControlStateNormal];
//  [back setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
//  [back setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
//  back.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
//  UIImage *backImage = [[UIImage imageNamed:@"navigationbar_button_back.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];  
//  [back setBackgroundImage:backImage forState:UIControlStateNormal];  
//  [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];  
//  UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:back] autorelease];
//  self.navigationItem.leftBarButtonItem = backButton;
}

// Subclasses may implement
- (void)setupLoadingAndEmptyViews {

}

// Called when the user logs out and we need to clear all cached data
// Subclasses should override this method
- (void)clearCachedData {
}

// Called when this card controller leaves active view
// Subclasses should override this method
- (void)unloadCardController {
  DLog(@"Called by class: %@", [self class]);
}

// Called when this card controller comes into active view
// Subclasses should override this method
- (void)reloadCardController {
  DLog(@"Called by class: %@", [self class]);
  [self updateState];
}

- (void)resetCardController {
  DLog(@"Called by class: %@", [self class]);
  [self updateState];  
}

// Subclass
- (void)dataSourceDidLoad {
  [self updateState];
}

#pragma mark CardStateMachine
/**
 If dataIsAvailable and !dataIsLoading and dataSourceIsReady, remove empty/loading screens
 If !dataIsAvailable and !dataIsLoading and dataSourceIsReady, show empty screen
 If dataIsLoading and !dataSourceIsReady, show loading screen
 If !dataIsLoading and !dataSourceIsReady, show empty/error screen
 */
//- (BOOL)dataIsAvailable;
//- (BOOL)dataIsLoading;
//- (BOOL)dataSourceIsReady;
//- (void)updateState;

- (BOOL)dataSourceIsReady {
  return YES;
}

- (BOOL)dataIsAvailable {
  return YES;
}

- (BOOL)dataIsLoading {
  return NO;
}

- (void)updateState {
//  if ([self dataIsAvailable]) {
//    // We have real data to display
//    [self hideLoadingView];
//  } else {
//    // We have no data to display, show the empty screen
//    [self showLoadingView];
//  }
}

- (void)updateScrollsToTop:(BOOL)isEnabled {
  if (_activeScrollView) {
    _activeScrollView.scrollsToTop = isEnabled;
  }
}


#pragma mark Loading
- (void)showLoadingView {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3];
  _emptyView.alpha = 1.0;
  [UIView commitAnimations];
}

- (void)hideLoadingView {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3];
  _emptyView.alpha = 0.0;
  [UIView commitAnimations];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//  DLog(@"nav will show controller: %@", [viewController class]);
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//  DLog(@"nav did show controller: %@", [viewController class]);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
//  return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  RELEASE_SAFELY(_emptyView);
  RELEASE_SAFELY(_navTitleLabel);
  [super dealloc];
}


@end

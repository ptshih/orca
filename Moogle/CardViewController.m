//
//  CardViewController.m
//  Moogle
//
//  Created by Peter Shih on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CardViewController.h"

@interface CardViewController (Private)

- (void)showLoadingView;
- (void)hideLoadingView;

@end

@implementation CardViewController

- (id)init {
  self = [super init];
  if (self) {
    _activeScrollView = nil;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
//  self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];

  // Setup Nav Bar
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
  
  self.navigationItem.titleView = navTitleView;
  [navTitleView release];
  
//  self.navigationController.navigationBar.tintColor = MOOGLE_BLUE_COLOR;
//  self.navigationItem.titleView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nav-logo.png"]] autorelease];
}

- (void)back {
  [self.navigationController popViewControllerAnimated:YES];
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
  return NO;
}

- (BOOL)dataIsAvailable {
  return NO;
}

- (BOOL)dataIsLoading {
  return NO;
}

- (void)updateState {
  if ([self dataIsAvailable]) {
    // We have real data to display
//      [self hideLoadingView];
  } else {
    // We have no data to display, show the empty screen
//      [self showEmptyView;
  }
}

- (void)updateScrollsToTop:(BOOL)isEnabled {
  if (_activeScrollView) {
    _activeScrollView.scrollsToTop = isEnabled;
  }
}


#pragma mark Loading
- (void)showLoadingView {
//  [self.view bringSubviewToFront:self.loadingView];
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3];
//  self.loadingView.frame = CGRectMake(0, 0, self.loadingView.width, self.loadingView.height);
  [UIView commitAnimations];
}

- (void)hideLoadingView {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.3];
//  self.loadingView.frame = CGRectMake(0, self.view.height, self.loadingView.width, self.loadingView.height);
  [UIView commitAnimations];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  DLog(@"nav will show controller: %@", [viewController class]);
  if ([viewController respondsToSelector:@selector(reloadCardController)]) {
    [viewController performSelector:@selector(reloadCardController)];
  }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
  DLog(@"nav did show controller: %@", [viewController class]);

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
  // e.g. self.myOutlet = nil;
}

- (void)dealloc {
  RELEASE_SAFELY(_navTitleLabel);
  [super dealloc];
}


@end

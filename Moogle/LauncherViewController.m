//
//  LauncherViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LauncherViewController.h"
#import "PodViewController.h"
#import "MeViewController.h"

@implementation LauncherViewController

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Set Page State
  _previousPage = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastSelectedCard"]; // Start at last selected card
  _currentPage = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastSelectedCard"]; // Start at last selected card
  
  // Setup Chrome
  [self setupChrome];
  
  // Setup Controllers
  [self setupControllers];
}

- (void)setupChrome { 
  // Setup CardScrollView
  _cardScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT)];
  _cardScrollView.delegate = self;
  _cardScrollView.contentSize = CGSizeMake(CARD_WIDTH * NUM_CARDS, 0);
  _cardScrollView.contentOffset = CGPointMake(CARD_WIDTH * _currentPage, 0); // start at page 1
  _cardScrollView.scrollsToTop = NO;
  _cardScrollView.pagingEnabled = YES;
  _cardScrollView.showsVerticalScrollIndicator = NO;
  _cardScrollView.showsHorizontalScrollIndicator = NO;
  
  [self.view addSubview:_cardScrollView];
}

- (void)setupControllers {
  // init the controllers
  _podViewController = [[PodViewController alloc] init];
  _meViewController = [[MeViewController alloc] init];
  _feedNavController = [[UINavigationController alloc] initWithRootViewController:_podViewController];
  _meNavController = [[UINavigationController alloc] initWithRootViewController:_meViewController];
  
  // Set nav delegates
  _feedNavController.delegate = _podViewController;
  _meNavController.delegate = _meViewController;
  
  // Add controllers to array
  _cards = [[NSArray alloc] initWithObjects:_feedNavController, _meNavController, nil];
  
  // Set frames for cards and add to card scroll view
  int i = 0;
  for (UINavigationController *card in _cards) {
    card.view.frame = CGRectMake(CARD_WIDTH * i, 0, CARD_WIDTH, CARD_HEIGHT);
    [_cardScrollView addSubview:card.view];
    i++;
  }
}

#pragma mark -
#pragma mark Card State Machine
- (void)updateScrollsToTop {
  // Because only ONE scrollView can have scrollsToTop set to YES under the entire view hieararchy, we need to loop thru all the cards and disable all scrollViews except for the one that is currently visible.
}

- (void)reloadVisibleCard {
  // Tell the new visible controller to reload it's data if it responds to it
  id visibleViewController = [_cards objectAtIndex:_currentPage];
  if ([[visibleViewController topViewController] respondsToSelector:@selector(reloadCardController)]) {
    [[visibleViewController topViewController] performSelector:@selector(reloadCardController)];
  }
}

- (void)updateCards {
  // Tell the previous controller to unload any data if it responds to it
  id previousViewController = [_cards objectAtIndex:_previousPage];
  if ([[previousViewController topViewController] respondsToSelector:@selector(unloadCardController)]) {
    [[previousViewController topViewController] performSelector:@selector(unloadCardController)];
  }
  
  // Tell the new visible controller to reload it's data if it responds to it
  id visibleViewController = [_cards objectAtIndex:_currentPage];
  if ([[visibleViewController topViewController] respondsToSelector:@selector(reloadCardController)]) {
    [[visibleViewController topViewController] performSelector:@selector(reloadCardController)];
  }
  
  // Update scrollsTopTop state
  for (UINavigationController *card in _cards) {
    CardViewController *cardController = (CardViewController *)[card topViewController];
    if ([cardController isEqual:[visibleViewController topViewController]]) {
      // Visible
      [cardController updateScrollsToTop:YES];
    } else {
      [cardController updateScrollsToTop:NO];
    }
  }
}

- (void)clearAllCachedData {
  
}

#pragma mark -
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
  // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
  // which a scroll event generated from the user hitting the page control triggers updates from
  // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
  if (_cardScrollView.contentOffset.x < 0 || _cardScrollView.contentOffset.x > (CARD_WIDTH * (NUM_CARDS - 1))) return;
  
  // Switch the indicator when more than 50% of the previous/next page is visible
  CGFloat pageWidth = _cardScrollView.frame.size.width;
  int page = floor((_cardScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
  _currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {  
  [self zoomOutBeforeScrolling];
}

// At the end of scroll animation, load the active view
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self zoomInAfterScrolling];
}

// Sometimes scrollViewDidEndDecelerating doesn't get called but this does instead
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [self zoomInAfterScrolling];
  }
}

// This is called when the scrolling stops after tapping a navigation button
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  [self zoomInAfterScrolling];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
  // Fire off something early (before the scroll view settles)
}

- (void)zoomOutBeforeScrolling {
  _previousPage = _currentPage;
  
  // When the user begins scrolling, zoom into card view
  for (UINavigationController *card in _cards) {
    [self zoomOut:card];
  }
}

- (void)zoomInAfterScrolling {
  // When the card is finished paging, zoom it out to take the full screen
  for (UINavigationController *card in _cards) {
    [self zoomIn:card];
  }
  
  // Only perform unload/reload if the card page actually changed
  if (_currentPage != _previousPage) {    
    [self updateCards];
  }
}

#pragma mark -
#pragma mark Animation
- (void)zoomIn:(UINavigationController *)card {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.1];
  card.view.transform = CGAffineTransformMakeScale(1,1);
  card.view.layer.cornerRadius = 0;
  card.view.layer.masksToBounds = YES;
  [UIView commitAnimations];
  
  // iOS4 ONLY
  //  [UIView animateWithDuration:0.2
  //      animations:^{
  //        card.navigationBar.hidden = NO;
  //        card.view.transform = CGAffineTransformMakeScale(1,1);
  //        card.topViewController.view.layer.cornerRadius = 0;
  //        card.topViewController.view.layer.masksToBounds = YES;
  //      }
  //      completion:^(BOOL finished){ 
  //        card.navigationBar.hidden = NO;
  //      }];
}

- (void)zoomOut:(UINavigationController *)card {
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDuration:0.2];
  card.view.transform = CGAffineTransformMakeScale(0.90,0.90);
  card.view.layer.cornerRadius = 6;
  card.view.layer.masksToBounds = YES;
  [UIView commitAnimations];
  
  // iOS4 ONLY
  //  [UIView animateWithDuration:0.2
  //      animations:^{
  //        card.view.transform = CGAffineTransformMakeScale(0.9,0.915);
  //        card.topViewController.view.layer.cornerRadius = 6;
  //        card.topViewController.view.layer.masksToBounds = YES;
  //      }
  //      completion:^(BOOL finished){ 
  //        card.navigationBar.hidden = YES;
  //      }];
}

#pragma mark -
#pragma mark Orientation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  // UI
  RELEASE_SAFELY(_cardScrollView);
  
  // Controllers
  RELEASE_SAFELY(_podViewController);
  RELEASE_SAFELY(_meViewController);
  
  // Card State
  RELEASE_SAFELY(_cards);
  
  [super dealloc];
}

@end
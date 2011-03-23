//
//  LauncherViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleViewController.h"

@class PodViewController;
@class MeViewController;

@interface LauncherViewController : MoogleViewController <UIScrollViewDelegate> {
  // UI
  UIScrollView *_cardScrollView;
  
  // Controllers
  UINavigationController *_feedNavController;
  UINavigationController *_meNavController;
  
  PodViewController *_podViewController;
  MeViewController *_meViewController;
  
  // Card State
  NSArray *_cards;
  NSInteger _currentPage;
  NSInteger _previousPage;
  
  // Config
}

// Cards
- (void)updateScrollsToTop;
- (void)reloadVisibleCard;
- (void)clearAllCachedData;

// Scrolling and Animations
- (void)zoomOutBeforeScrolling;
- (void)zoomInAfterScrolling;
- (void)zoomIn:(UINavigationController *)card;
- (void)zoomOut:(UINavigationController *)card;

// Private
- (void)setupChrome;
- (void)setupControllers;

@end

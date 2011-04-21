//
//  LauncherViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LauncherViewController : UIViewController <UIScrollViewDelegate, UITabBarDelegate> {
  UIScrollView *_cardScrollView;
  UITabBar *_cardTabBar;
  
  NSArray *_cards;
  NSInteger _currentPage;
  NSInteger _previousPage;
  
  BOOL _isQuickScroll;
}

@property (nonatomic, retain) NSArray *cards;

// Cards
- (void)updateScrollsToTop;
- (void)reloadVisibleCard;
- (void)clearAllCachedData;

// Tab
- (void)scrollToCardAtIndex:(NSInteger)index;

// Scrolling and Animations
- (void)zoomOutBeforeScrolling;
- (void)zoomInAfterScrolling;
- (void)zoomIn:(UINavigationController *)card;
- (void)zoomOut:(UINavigationController *)card;

// Private
- (void)setupChrome;
- (void)setupControllers;

@end

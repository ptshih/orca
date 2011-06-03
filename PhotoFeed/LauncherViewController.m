//
//  LauncherViewController.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LauncherViewController.h"
#import "AlbumViewController.h"

static UIImage *_actionImage = nil;


@implementation LauncherViewController

+ (void)initialize {
  _actionImage = [[UIImage imageNamed:@"tab_action.png"] retain];
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [_tabBarController viewWillAppear:animated];
}

- (void)loadView {
  [super loadView];
  self.wantsFullScreenLayout = YES;
  
  _tabBarController = [[UITabBarController alloc] init];
  _tabBarController.delegate = self;
  _tabBarController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  
  // Setup Tabs
  AlbumViewController *timeline = [[[AlbumViewController alloc] init] autorelease];
  timeline.albumType = AlbumTypeTimeline;
  UINavigationController *timelineNav = [[[UINavigationController alloc] initWithRootViewController:timeline] autorelease];
  
  AlbumViewController *favorites = [[[AlbumViewController alloc] init] autorelease];
  favorites.albumType = AlbumTypeFavorites;
  UINavigationController *favoritesNav = [[[UINavigationController alloc] initWithRootViewController:favorites] autorelease];
  
  AlbumViewController *search = [[[AlbumViewController alloc] init] autorelease];
  search.albumType = AlbumTypeTimeline;
  UINavigationController *searchNav = [[[UINavigationController alloc] initWithRootViewController:search] autorelease];
  
  AlbumViewController *history = [[[AlbumViewController alloc] init] autorelease];
  history.albumType = AlbumTypeHistory;
  UINavigationController *historyNav = [[[UINavigationController alloc] initWithRootViewController:history] autorelease];
  
  UIViewController *more = [[[UIViewController alloc] init] autorelease];
  UINavigationController *moreNav = [[[UINavigationController alloc] initWithRootViewController:more] autorelease];
  
  // Setup Tab Items
  timeline.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Albums" image:[UIImage imageNamed:@"42-photos.png"] tag:7001] autorelease];
  favorites.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:7002] autorelease];
  search.tabBarItem = nil;
  history.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemHistory tag:7004] autorelease];
  more.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:7005] autorelease];
  
  // Set Tab Controllers
  _tabBarController.viewControllers = [NSArray arrayWithObjects:timelineNav, favoritesNav, searchNav, historyNav, moreNav, nil];
  
  // Add to view
  self.view = _tabBarController.view;
  
  // Select previously chosen tab
  _tabBarController.selectedViewController = [_tabBarController.viewControllers objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"lastSelectedTab"]];
  
  // Custom tab action button
  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.frame = CGRectMake(130.0, 3.0, _actionImage.size.width, _actionImage.size.height);
  [button setBackgroundImage:_actionImage forState:UIControlStateNormal];
  [button addTarget:self action:@selector(selectActionButton) forControlEvents:UIControlEventTouchUpInside];
  
  [_tabBarController.tabBar addSubview:button];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
  NSUInteger tabIndex = [_tabBarController.viewControllers indexOfObject:viewController];
  [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:tabIndex] forKey:@"lastSelectedTab"];
}

- (void)selectActionButton {
  _tabBarController.selectedViewController = [_tabBarController.viewControllers objectAtIndex:2];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//  return YES;
//}

- (void)dealloc {
  RELEASE_SAFELY(_tabBarController);
  [super dealloc];
}

@end

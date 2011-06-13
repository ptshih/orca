//
//  LauncherViewController.m
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LauncherViewController.h"
#import "PodViewController.h"
#import "MoreViewController.h"

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
  PodViewController *pods = [[[PodViewController alloc] init] autorelease];
  UINavigationController *podsNav = [[[UINavigationController alloc] initWithRootViewController:pods] autorelease];
  
  MoreViewController *more = [[[MoreViewController alloc] init] autorelease];
  UINavigationController *moreNav = [[[UINavigationController alloc] initWithRootViewController:more] autorelease];
  
  // Setup Tab Items
  pods.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Pods" image:[UIImage imageNamed:@"tab_feed.png"] tag:7001] autorelease];
  more.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemMore tag:7005] autorelease];
  
  // Set Tab Controllers
  _tabBarController.viewControllers = [NSArray arrayWithObjects:podsNav, moreNav, nil];
  
  // Add to view
  self.view = _tabBarController.view;
  
  // Select previously chosen tab
  _tabBarController.selectedViewController = [_tabBarController.viewControllers objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"lastSelectedTab"]];
  
  // Custom tab action button
//  UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//  button.frame = CGRectMake(130.0, 3.0, _actionImage.size.width, _actionImage.size.height);
//  [button setBackgroundImage:_actionImage forState:UIControlStateNormal];
//  [button addTarget:self action:@selector(selectActionButton) forControlEvents:UIControlEventTouchUpInside];
//  
//  [_tabBarController.tabBar addSubview:button];
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

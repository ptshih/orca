//
//  LauncherViewController.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LauncherViewController.h"
#import "AlbumViewController.h"

@implementation LauncherViewController

- (id)init {
  self = [super init];
  if (self) {
    _tabBarController = [[UITabBarController alloc] init];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [_tabBarController viewWillAppear:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Setup Tabs
  AlbumViewController *avc = [[AlbumViewController alloc] init];
  UINavigationController *anc = [[UINavigationController alloc] initWithRootViewController:avc];
  
  // Setup Tab Items
  avc.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:7000] autorelease];
  
  // Set Tab Controllers
  _tabBarController.viewControllers = [NSArray arrayWithObjects:anc, nil];
  
  // Add to view
  self.view = _tabBarController.view;
}

- (void)dealloc {
  RELEASE_SAFELY(_tabBarController);
  [super dealloc];
}

@end

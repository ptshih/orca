//
//  LauncherViewController.m
//  Scrapboard
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
  }
  return self;
}

- (void)loadView {
  [super loadView];
  self.wantsFullScreenLayout = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _avc = [[AlbumViewController alloc] init];
  _anc = [[UINavigationController alloc] initWithRootViewController:_avc];
  [self.view addSubview:_anc.view];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  RELEASE_SAFELY(_avc);
  RELEASE_SAFELY(_anc);
  [super dealloc];
}

@end

//
//  MeViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MeViewController.h"
#import "MeDataCenter.h"

@implementation MeViewController

- (id)init {
  self = [super init];
  if (self) {
    _meDataCenter = [[MeDataCenter alloc ]init];
    _meDataCenter.delegate = self;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
  
  _navTitleLabel.text = @"Moogle Me";
  
  [self showDismissButton];
  
  // Setup Table
  [self setupTableViewWithFrame:self.view.bounds andStyle:UITableViewStyleGrouped andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  // Get the Me data from the server
  [_meDataCenter requestMe];
}


#pragma mark MoogleDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {

}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {

}


- (void)dealloc {  
  RELEASE_SAFELY(_meDataCenter);
  [super dealloc];
}

@end

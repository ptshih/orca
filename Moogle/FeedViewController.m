//
//  FeedViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedDataCenter.h"

@implementation FeedViewController

@synthesize podId = _podId;

- (id)init {
  self = [super init];
  if (self) {
    _feedDataCenter = [[FeedDataCenter alloc] init];
    _feedDataCenter.delegate = self;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT_WITH_NAV);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  // Load Fixtures
  [_feedDataCenter loadFeedsFromFixture];
}

#pragma mark -
#pragma mark MoogleDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self resetFetchedResultsController];
  [self.tableView reloadData];
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_feedDataCenter getFeedsFetchRequestForPod:self.podId];
}

- (void)dealloc {
  RELEASE_SAFELY(_feedDataCenter);
  RELEASE_SAFELY(_podId);
  [super dealloc];
}

@end
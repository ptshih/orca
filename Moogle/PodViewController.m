//
//  PodViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PodViewController.h"
#import "PodDataCenter.h"
#import "FeedViewController.h"
#import "Pod.h"

@implementation PodViewController

- (id)init {
  self = [super init];
  if (self) {
    _podDataCenter = [[PodDataCenter alloc] init];
    _podDataCenter.delegate = self;
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
  [_podDataCenter loadPodsFromFixture];
}


#pragma mark -
#pragma mark TableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Pod *pod = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  FeedViewController *fvc = [[FeedViewController alloc] init];
  fvc.podId = pod.id;
  [self.navigationController pushViewController:fvc animated:YES];
  [fvc release];
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
  return [_podDataCenter getPodsFetchRequest];
}

- (void)dealloc {
  RELEASE_SAFELY(_podDataCenter);
  [super dealloc];
}

@end
//
//  SnapViewController.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SnapViewController.h"
#import "SnapDataCenter.h"

@implementation SnapViewController

@synthesize albumId = _albumId;

- (id)init {
  self = [super init];
  if (self) {
    _snapDataCenter = [[SnapDataCenter alloc] init];
    _snapDataCenter.delegate = self;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _navTitleLabel.text = @"Snaps";
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT - 44);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  [self resetFetchedResultsController];
  [self executeFetch];
  [self reloadCardController];
}

- (void)reloadCardController {
  [super reloadCardController];
  
  [_snapDataCenter getSnapsForAlbumWithAlbumId:_albumId];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_snapDataCenter getSnapsFetchRequestWithAlbumId:_albumId];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  NSLog(@"DC finish with response: %@", response);
  [self dataSourceDidLoad];
  [self executeFetch];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self dataSourceDidLoad];
}

- (void)dealloc {
  RELEASE_SAFELY(_albumId);
  RELEASE_SAFELY(_snapDataCenter);
  [super dealloc];
}

@end

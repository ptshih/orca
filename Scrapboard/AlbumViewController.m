//
//  AlbumViewController.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumViewController.h"
#import "AlbumDataCenter.h"

@implementation AlbumViewController

- (id)init {
  self = [super init];
  if (self) {
    _albumDataCenter = [[AlbumDataCenter alloc] init];
    _albumDataCenter.delegate = self;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _navTitleLabel.text = @"Albums";
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT - 44);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  [self setupSearchDisplayControllerWithScopeButtonTitles:[NSArray arrayWithObjects:@"Album", @"Person", nil]];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  [self resetFetchedResultsController];
  [self executeFetch];
  [self reloadCardController];
}

- (void)reloadCardController {
  [super reloadCardController];
  
  [_albumDataCenter getAlbums];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  NSPredicate *predicate = nil;
  
  if ([scope isEqualToString:@"Person"]) {
    // search friend's full name
    predicate = [NSPredicate predicateWithFormat:@"participantFullNames CONTAINS[cd] %@ OR userName CONTAINS[cd] %@", searchText, searchText];
  } else {
    // default to album name
    predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  }
  
  [_searchItems removeAllObjects];
  [_searchItems addObjectsFromArray:[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:predicate]];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_albumDataCenter getAlbumsFetchRequest];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  NSLog(@"DC finish with response: %@", response);
  [self dataSourceDidLoad];
  [self executeFetch];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  
}

- (void)dealloc {
  RELEASE_SAFELY(_albumDataCenter);
  [super dealloc];
}
@end

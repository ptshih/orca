//
//  AlbumViewController.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumViewController.h"
#import "AlbumDataCenter.h"
#import "SnapViewController.h"
#import "Album.h"

@implementation AlbumViewController

- (id)init {
  self = [super init];
  if (self) {
    _albumDataCenter = [[AlbumDataCenter alloc] init];
    _albumDataCenter.delegate = self;
    _sectionNameKeyPathForFetchedResultsController = @"daysAgo";
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
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
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
#pragma mark TableView

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
  
  Album *album = nil;
  if (tableView != self.searchDisplayController.searchResultsTableView) {
    album = [[self.fetchedResultsController fetchedObjects] objectAtIndex:section];
  } else {
    album = [_searchItems objectAtIndex:section];
  }
  return album.name;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Album *album = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    album = [_searchItems objectAtIndex:indexPath.row];
  } else {
    album = [self.fetchedResultsController objectAtIndexPath:indexPath];
  }
  
  // Mark isRead state
  //  if (![event.isRead boolValue]) {
  //    event.isRead = [NSNumber numberWithBool:YES];
  //    
  //    NSError *error = nil;
  //    if ([self.context hasChanges]) {
  //      if (![self.context save:&error]) {
  //        abort(); // NOTE: DO NOT SHIP
  //      }
  //    }
  //  }
  
  SnapViewController *svc = [[SnapViewController alloc] init];
  svc.album = album;
  [self.navigationController pushViewController:svc animated:YES];
  [svc release];
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
  [self dataSourceDidLoad];
}

- (void)dealloc {
  RELEASE_SAFELY(_albumDataCenter);
  [super dealloc];
}

@end

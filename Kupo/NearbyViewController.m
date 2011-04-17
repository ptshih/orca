//
//  NearbyViewController.h.m
//  Kupo
//
//  Created by Peter Shih on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbyViewController.h"
#import "NearbyDataCenter.h"
#import "KupoLocation.h"
#import "NearbyCell.h"
#import "Nearby.h"
#import "ComposeViewController.h"

@interface NearbyViewController (Private)

- (void)locationAcquired;

@end

@implementation NearbyViewController

- (id)init {
  self = [super init];
  if (self) {
    [[NearbyDataCenter defaultCenter] setDelegate:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _navTitleLabel.text = @"Nearby Places";
  
  [self showDismissButton];
  
  // Setup Table
  [self setupTableViewWithFrame:self.view.bounds andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
//  [self setupPullRefresh];
  
  [self setupSearchDisplayControllerWithScopeButtonTitles:nil];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateState];
  [[KupoLocation sharedInstance] startStandardUpdates];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAcquired) name:kLocationAcquired object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[KupoLocation sharedInstance] stopStandardUpdates];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationAcquired object:nil];
}

- (void)locationAcquired {
  [[NearbyDataCenter defaultCenter] getNearbyPlaces];
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self.sections removeAllObjects];
  [self.sections addObject:@"Places"];
  
  [self.items removeAllObjects];
  [self.items addObject:[[NearbyDataCenter defaultCenter] nearbyPlaces]];
  [_tableView reloadData];
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  [self dataSourceDidLoad];
}

#pragma mark TableView Stuff
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  return [NearbyCell rowHeightForObject:item];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [_searchBar resignFirstResponder];
  
  Nearby *nearbyPlace = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    nearbyPlace = [self.searchItems objectAtIndex:indexPath.row];
  } else {
    nearbyPlace = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  }
  
  ComposeViewController *kcvc = [[ComposeViewController alloc] init];
  kcvc.kupoComposeType = KupoComposeTypeCheckin;
  kcvc.eventId = nearbyPlace.id;
  [self.navigationController pushViewController:kcvc animated:YES];
  [kcvc release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell", [self class]];
  NearbyCell *cell = nil;
  cell = (NearbyCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[NearbyCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  Nearby *nearbyPlace = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    nearbyPlace = [self.searchItems objectAtIndex:indexPath.row];
  } else {
    nearbyPlace = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  }
  
  [cell fillCellWithObject:nearbyPlace];
  [cell loadMap];
  return cell;
}

#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  [self.searchItems removeAllObjects];
  
  if ([self.items count] == 0) {
    return;
  }
  
  NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  
  [_searchItems addObjectsFromArray:[[self.items objectAtIndex:0] filteredArrayUsingPredicate:predicate]];
}

#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
//  if ([[KupoLocation sharedInstance] hasAcquiredLocation]) {
//    [_placesDataCenter getNearbyPlaces];
//  }
}

- (void)unloadCardController {
  [super unloadCardController];
}

- (void)dealloc {
  [[NearbyDataCenter defaultCenter] setDelegate:nil];
  [super dealloc];
}


@end

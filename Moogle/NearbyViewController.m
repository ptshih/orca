//
//  NearbyViewController.h.m
//  Moogle
//
//  Created by Peter Shih on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbyViewController.h"
#import "NearbyDataCenter.h"
#import "MoogleLocation.h"
#import "NearbyCell.h"
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
  [self setupTableViewWithFrame:self.view.bounds andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
//  [self setupPullRefresh];
  
  [self setupSearchDisplayControllerWithScopeButtonTitles:nil];
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[MoogleLocation sharedInstance] startStandardUpdates];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationAcquired) name:kLocationAcquired object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[MoogleLocation sharedInstance] stopStandardUpdates];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationAcquired object:nil];
}

- (void)locationAcquired {
  [[NearbyDataCenter defaultCenter] getNearbyPlaces];
}

#pragma mark MoogleDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self.sections removeAllObjects];
  [self.sections addObject:@"Places"];
  
  [self.items removeAllObjects];
  [self.items addObject:[[[NearbyDataCenter defaultCenter] response] valueForKey:@"values"]];
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
  
  NSDictionary *place = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    place = [self.searchItems objectAtIndex:indexPath.row];
  } else {
    place = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  }
  
  ComposeViewController *kcvc = [[ComposeViewController alloc] init];
  kcvc.moogleComposeType = MoogleComposeTypeCheckin;
  kcvc.placeId = [place valueForKey:@"place_id"];
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
  
  NSDictionary *place = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    place = [self.searchItems objectAtIndex:indexPath.row];
  } else {
    place = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  }
  
  [cell fillCellWithObject:place];
  [cell loadImage];
  return cell;
}

#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  [self.searchItems removeAllObjects];
  
  if ([self.items count] == 0) {
    return;
  }
  
  for (NSDictionary *place in [self.items objectAtIndex:0]) {
    NSComparisonResult result = [[place valueForKey:@"place_name"] compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
    if (result == NSOrderedSame) {
      [self.searchItems addObject:place];
    }
  }
}

#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
//  if ([[MoogleLocation sharedInstance] hasAcquiredLocation]) {
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

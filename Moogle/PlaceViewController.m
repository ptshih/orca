//
//  PlaceViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceViewController.h"
#import "PlaceDataCenter.h"
#import "KupoViewController.h"
#import "MeViewController.h"
#import "NearbyViewController.h"
#import "Place.h"
#import "PlaceCell.h"

@implementation PlaceViewController

- (id)init {
  self = [super init];
  if (self) {
    [[PlaceDataCenter defaultCenter] setDelegate:self];
    
    _limit = 50;
    
    _shouldReloadOnAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kComposeDidFinish object:nil];
  }
  return self;
}

- (void)coreDataDidReset {
  _shouldReloadOnAppear = YES;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"profile_nav_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(profile)];
  self.navigationItem.leftBarButtonItem = leftButton;
  [leftButton release];
  
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"place_nav_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(checkin)];
  self.navigationItem.rightBarButtonItem = rightButton;
  [rightButton release];
  
  // Nav Title
  _navTitleLabel.text = @"Moogle";
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  [self setupSearchDisplayControllerWithScopeButtonTitles:[NSArray arrayWithObjects:@"Place", @"Person", nil]];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  // Load More
  [self setupLoadMoreView];
  
//  UIBarButtonItem *post = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(post)];
//  self.navigationItem.rightBarButtonItem = post;
//  [post release];
  
  [self reloadCardController];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  if (_shouldReloadOnAppear) {
    _shouldReloadOnAppear = NO;
    [self reloadCardController];
  }
}

- (void)profile {
  if (!_meViewController) {
    _meViewController = [[MeViewController alloc] init];
    _meViewController.delegate = self;
  }
  if (!_meNavController) {
    _meNavController = [[UINavigationController alloc] initWithRootViewController:_meViewController];
  }
  [self presentModalViewController:_meNavController animated:YES];
}

- (void)checkin {
  if (!_nearbyViewController) {
    _nearbyViewController = [[NearbyViewController alloc] init];
  }
  
  if (!_nearbyNavController) {
    _nearbyNavController = [[UINavigationController alloc] initWithRootViewController:_nearbyViewController];
  }
  
  [self presentModalViewController:_nearbyNavController animated:YES];
}

#pragma mark -
#pragma mark TableView
- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Place *place = nil;
  if (_tableView == self.searchDisplayController.searchResultsTableView) {
    place = [_searchItems objectAtIndex:indexPath.row];
  } else {
    place = [self.fetchedResultsController objectAtIndexPath:indexPath];
  }
  
  [cell fillCellWithObject:place];
  [cell setNeedsDisplay];
  [cell loadImage];
  [cell loadFriendPictures];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Place *place = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    place = [_searchItems objectAtIndex:indexPath.row];
  } else {
    place = [self.fetchedResultsController objectAtIndexPath:indexPath];
  }
  
  return [PlaceCell rowHeightForObject:place];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Place *place = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    place = [_searchItems objectAtIndex:indexPath.row];
  } else {
    place = [self.fetchedResultsController objectAtIndexPath:indexPath];
  }
    
  KupoViewController *kvc = [[KupoViewController alloc] init];
  kvc.place = place;
  [self.navigationController pushViewController:kvc animated:YES];
  [kvc release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  PlaceCell *cell = nil;
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell_%d", [self class], indexPath.section];
  
  cell = (PlaceCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[PlaceCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  [self configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  NSPredicate *predicate = nil;
  
  if ([scope isEqualToString:@"Person"]) {
    // search friend's full name
    predicate = [NSPredicate predicateWithFormat:@"friendFullNames CONTAINS[cd] %@", searchText];
  } else {
    // default to place name
    predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  }
  
  [_searchItems removeAllObjects];
  [_searchItems addObjectsFromArray:[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:predicate]];
}


#pragma mark -
#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
  [self executeFetch];
  [[PlaceDataCenter defaultCenter] getPlaces];
//  [[PlaceDataCenter defaultCenter] loadPlacesFromFixture];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark MoogleDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark LoadMore
- (void)loadMore {
  [super loadMore];
  [[PlaceDataCenter defaultCenter] loadMorePlaces];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [[PlaceDataCenter defaultCenter] getPlacesFetchRequest];
}

#pragma mark -
#pragma mark MeDelegate
- (void)logoutRequested {
  UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"Logout of Moogle?" message:MOOGLE_LOGOUT_ALERT delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
  [logoutAlert show];
  [logoutAlert autorelease];
}

#pragma mark -
#pragma mark AlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex != alertView.cancelButtonIndex) {
  [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutRequested object:nil];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kCoreDataDidReset object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kComposeDidFinish object:nil];
  [[PlaceDataCenter defaultCenter] setDelegate:nil];
  RELEASE_SAFELY(_nearbyViewController);
  RELEASE_SAFELY(_meViewController);
  RELEASE_SAFELY(_nearbyNavController);
  RELEASE_SAFELY(_meNavController);
  [super dealloc];
}

@end
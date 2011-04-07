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
#import "PlacesViewController.h"
#import "Place.h"
#import "PlaceCell.h"

@implementation PlaceViewController

- (id)init {
  self = [super init];
  if (self) {
    _placeDataCenter = [[PlaceDataCenter alloc] init];
    _placeDataCenter.delegate = self;
    
    _limit = 50;
    
    _shouldReloadOnAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDeletedAllObjects object:nil];
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
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
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
  MeViewController *mvc = [[MeViewController alloc] init];
  mvc.delegate = self;
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mvc];
//  navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self presentModalViewController:navController animated:YES];
  [mvc release];
  [navController release];  
}

- (void)checkin {
  PlacesViewController *mvc = [[PlacesViewController alloc] init];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mvc];
  //  navController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self presentModalViewController:navController animated:YES];
  [mvc release];
  [navController release];  
}



#pragma mark -
#pragma mark TableView
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
  
  Place *place = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    place = [_searchItems objectAtIndex:indexPath.row];
  } else {
    place = [self.fetchedResultsController objectAtIndexPath:indexPath];
  }
  
  [cell fillCellWithObject:place];
  [cell loadImage];
  [cell setNeedsDisplay];
  
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
  
  [_placeDataCenter getPlaces];
//  [_placeDataCenter loadPlacesFromFixture];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark MoogleDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self resetFetchedResultsController];
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  [self resetFetchedResultsController];
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark LoadMore
- (void)loadMore {
  [super loadMore];
  [_placeDataCenter loadMorePlaces];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_placeDataCenter getPlacesFetchRequest];
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
  RELEASE_SAFELY(_placeDataCenter);
  [super dealloc];
}

@end
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
  }
  return self;
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
  
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadCardController];
}

- (void)profile {
  MeViewController *mvc = [[MeViewController alloc] init];
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
  return 60;
  Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  return [PlaceCell rowHeightForObject:place];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  // Mark isRead state
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  place.isRead = [NSNumber numberWithBool:YES];
  
  NSError *error = nil;
  if ([context hasChanges]) {
    if (![context save:&error]) {
      abort(); // NOTE: DO NOT SHIP
    }
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
  
  Place *place = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:place];
  [cell loadImage];
  [cell setNeedsDisplay];
  
  return cell;
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
  [self executeFetchWithPredicate:nil];
  [self dataSourceDidLoad];
  
  // Is this a load more call?
//  BOOL isLoadMore = [[operation requestParams] objectForKey:@"until"] ? YES : NO;
//  if (isLoadMore) {
//    NSInteger responseCount = [[_placeDataCenter.response valueForKey:@"count"] integerValue];
//    if (responseCount > 0) {
//      [self showLoadMoreView];
//    } else {
//      [self hideLoadMoreView];
//    }
//  }
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  [self executeFetchWithPredicate:nil];
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark LoadMore
- (void)loadMore {
  [_placeDataCenter loadMorePlaces];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_placeDataCenter getPlacesFetchRequest];
}

- (void)dealloc {
  RELEASE_SAFELY(_placeDataCenter);
  [super dealloc];
}

@end
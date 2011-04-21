//
//  EventViewController.m
//  Scrapboard
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventViewController.h"

@implementation EventViewController

@synthesize shouldReloadOnAppear = _shouldReloadOnAppear;

- (id)init {
  self = [super init];
  if (self) {
    _shouldReloadOnAppear = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kReloadController object:nil];
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
  
//  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"event_nav_icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(checkin)];
//  self.navigationItem.rightBarButtonItem = rightButton;
//  [rightButton release];
  
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newEvent)];
  self.navigationItem.rightBarButtonItem = rightButton;
  [rightButton release];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  [self setupSearchDisplayControllerWithScopeButtonTitles:[NSArray arrayWithObjects:@"Event", @"Person", nil]];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  // Load More
  [self setupLoadMoreView];
  
  [self executeFetch];
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
    [self reloadCardController];
  }
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

- (void)newEvent {
  EventComposeViewController *ecvc = [[EventComposeViewController alloc] init];
  UINavigationController *eventComposeNav = [[UINavigationController alloc] initWithRootViewController:ecvc];
  [self presentModalViewController:eventComposeNav animated:YES];
  [ecvc release];
  [eventComposeNav release];
}

#pragma mark -
#pragma mark TableView
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
  [(EventCell *)cell loadImage];
  [(EventCell *)cell loadParticipantPictures];
  [cell setNeedsDisplay];
  [cell setNeedsLayout];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Event *event = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    event = [_searchItems objectAtIndex:indexPath.row];
  } else {
    event = [self.fetchedResultsController objectAtIndexPath:indexPath];
  }
  
  [cell fillCellWithObject:event];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Event *event = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    event = [_searchItems objectAtIndex:indexPath.row];
  } else {
    event = [self.fetchedResultsController objectAtIndexPath:indexPath];
  }
  
  return [EventCell rowHeightForObject:event];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Event *event = nil;
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    event = [_searchItems objectAtIndex:indexPath.row];
  } else {
    event = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
  
  KupoViewController *kvc = [[KupoViewController alloc] init];
  kvc.event = event;
  [self.navigationController pushViewController:kvc animated:YES];
  [kvc release];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  EventCell *cell = nil;
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell_%d", [self class], indexPath.section];
  
  cell = (EventCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[EventCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  [self tableView:tableView configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  NSPredicate *predicate = nil;
  
  if ([scope isEqualToString:@"Person"]) {
    // search friend's full name
    predicate = [NSPredicate predicateWithFormat:@"friendFullNames CONTAINS[cd] %@ OR authorName CONTAINS[cd] %@", searchText, searchText];
  } else {
    // default to event name
    predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  }
  
  [_searchItems removeAllObjects];
  [_searchItems addObjectsFromArray:[[self.fetchedResultsController fetchedObjects] filteredArrayUsingPredicate:predicate]];
}


#pragma mark -
#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
  
  // Get since date
//  NSDate *sinceDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"since.events"];
//  [[EventDataCenter defaultCenter] getEventsWithSince:sinceDate];
//  [[EventDataCenter defaultCenter] loadEventsFromFixture];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self dataSourceDidLoad];
  
  [self executeFetch];
  
//  if ([self.fetchedResultsController.fetchedObjects count] > 0) {
//    // Set since and until date
//    Event *firstEvent = [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
//    Event *lastEvent = [[self.fetchedResultsController fetchedObjects] lastObject];
//    NSDate *sinceDate = firstEvent.timestamp;
//    NSDate *untilDate = lastEvent.timestamp;
//    [[NSUserDefaults standardUserDefaults] setValue:sinceDate forKey:@"since.events"];
//    [[NSUserDefaults standardUserDefaults] setValue:untilDate forKey:@"until.events"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//  }
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark LoadMore
- (void)loadMore {
  [super loadMore];
  
  // get until date
//  NSDate *untilDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"until.events"];
//  [[EventDataCenter defaultCenter] loadMoreEventsWithUntil:untilDate];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
//  return [[EventDataCenter defaultCenter] getEventsFetchRequest];
  return nil;
}

#pragma mark -
#pragma mark MeDelegate
- (void)logoutRequested {
  UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"Logout of Kupo?" message:LOGOUT_ALERT delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
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
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadController object:nil];
  RELEASE_SAFELY(_meViewController);
  RELEASE_SAFELY(_meNavController);
  [super dealloc];
}

@end
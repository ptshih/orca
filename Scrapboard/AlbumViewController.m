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
#import "AlbumCell.h"
#import "Album.h"
#import "CameraViewController.h"

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
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kReloadController object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadController object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Title and Buttons
  _navTitleLabel.text = @"Albums";
  
  UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
  self.navigationItem.leftBarButtonItem = leftButton;
  [leftButton release];  
  
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(newAlbum)];
  self.navigationItem.rightBarButtonItem = rightButton;
  [rightButton release];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
  [self setupSearchDisplayControllerWithScopeButtonTitles:[NSArray arrayWithObjects:@"Album", @"Person", nil]];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  [self resetFetchedResultsController];
  [self executeFetch];
  [self updateState];
}

- (void)reloadCardController {
  [super reloadCardController];
  
  [_albumDataCenter getAlbums];
}

- (void)unloadCardController {
  [super unloadCardController];
}

- (void)newAlbum {
  CameraViewController *cvc = [[CameraViewController alloc] init];
  UINavigationController *cnc = [[UINavigationController alloc] initWithRootViewController:cvc];
  [self presentModalViewController:cnc animated:NO];
  [cvc autorelease];
  [cnc autorelease];
}

#pragma mark -
#pragma mark TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [AlbumCell rowHeightForObject:album forInterfaceOrientation:[self interfaceOrientation]];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:album];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  AlbumCell *cell = nil;
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell_%d", [self class], indexPath.section];
  
  cell = (AlbumCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[AlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  [self tableView:tableView configureCell:cell atIndexPath:indexPath];
  
  // Initial static render of cell
  if (tableView.dragging == NO && tableView.decelerating == NO) {
    [cell loadImage];
    [cell loadPhoto];
  }
  
  return cell;
}

- (void)loadImagesForOnScreenRows {
  [super loadImagesForOnScreenRows];
  
  for (id cell in _visibleCells) {
    [cell loadImage];
    [cell loadPhoto];
  }
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  NSPredicate *predicate = nil;
  
  if ([scope isEqualToString:@"Person"]) {
    // search friend's full name
    predicate = [NSPredicate predicateWithFormat:@"userName CONTAINS[cd] %@", searchText, searchText];
  } else {
    // default to album name
    predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  }
  
  [self.fetchedResultsController.fetchRequest setPredicate:predicate];
  [self executeFetch];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_albumDataCenter getAlbumsFetchRequest];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
//  NSLog(@"DC finish with response: %@", response);
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self dataSourceDidLoad];
}

- (void)logout {
  UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"Logout?" message:LOGOUT_ALERT delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
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
  RELEASE_SAFELY(_albumDataCenter);
  [super dealloc];
}

@end

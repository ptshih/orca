//
//  AlbumViewController.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumViewController.h"
#import "AlbumDataCenter.h"
#import "PhotoViewController.h"
#import "AlbumCell.h"
#import "Album.h"
#import "CameraViewController.h"

@implementation AlbumViewController

@synthesize albumType = _albumType;

- (id)init {
  self = [super init];
  if (self) {
    _sectionNameKeyPathForFetchedResultsController = [@"daysAgo" retain];
    _albumType = AlbumTypeMe;
    
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kReloadAlbumController object:nil];
  [self reloadCardController];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadAlbumController object:nil];
}

- (void)loadView {
  [super loadView];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
  // Album Type
  NSArray *scopeArray = nil;
  NSString *placeholder = nil;
  NSString *navTitle = nil;
  switch (self.albumType) {
    case AlbumTypeMe:
      navTitle = @"My Albums";
      placeholder = @"Search by Album Name";
      scopeArray = [NSArray arrayWithObjects:@"Album", nil];
      break;
    case AlbumTypeFriends:
      navTitle = @"Friends Albums";
      placeholder = @"Search by Album or Author Name";
      scopeArray = [NSArray arrayWithObjects:@"Album", @"Author", nil];
      break;
    case AlbumTypeWall:
      navTitle = @"Wall Photos";
      placeholder = @"Search by Author Name";
      scopeArray = [NSArray arrayWithObjects:@"Author", nil];
      break;
    case AlbumTypeMobile:
      navTitle = @"Mobile Uploads";
      placeholder = @"Search by Author Name";
      scopeArray = [NSArray arrayWithObjects:@"Author", nil];
      break;
    case AlbumTypeProfile:
      navTitle = @"Profile Pictures";
      placeholder = @"Search by Author Name";
      scopeArray = [NSArray arrayWithObjects:@"Author", nil];
      break;
    default:
      break;
  }
  
  // Search Scope
  [self setupSearchDisplayControllerWithScopeButtonTitles:scopeArray andPlaceholder:placeholder];
  
  // Title and Buttons
  [self addButtonWithTitle:@"Logout" andSelector:@selector(logout) isLeft:YES];
//  [self addButtonWithTitle:@"New" andSelector:@selector(newAlbum) isLeft:NO];
  _navTitleLabel.text = navTitle;
  
  
  // Pull Refresh
//  [self setupPullRefresh];
  [self setupLoadMoreView];
  
  [self resetFetchedResultsController];
}

- (void)reloadCardController {
  [super reloadCardController];
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
    [self dataSourceDidLoad];
  }
}

- (void)unloadCardController {
  [super unloadCardController];
}

- (void)newAlbum {
  //  CameraViewController *cvc = [[CameraViewController alloc] init];
  //  UINavigationController *cnc = [[UINavigationController alloc] initWithRootViewController:cvc];
  //  [self presentModalViewController:cnc animated:NO];
  //  [cvc autorelease];
  //  [cnc autorelease];
}

#pragma mark -
#pragma mark TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [AlbumCell rowHeightForObject:album forInterfaceOrientation:[self interfaceOrientation]];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//  return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  NSString *sectionName = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
  
  UIView *sectionHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 26)] autorelease];
  sectionHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_plain_header_gray.png"]];
  
  UILabel *sectionHeaderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 310, 26)] autorelease];
  sectionHeaderLabel.backgroundColor = [UIColor clearColor];
  sectionHeaderLabel.text = sectionName;
  sectionHeaderLabel.textColor = [UIColor whiteColor];
  sectionHeaderLabel.shadowColor = [UIColor blackColor];
  sectionHeaderLabel.shadowOffset = CGSizeMake(0, 1);
  sectionHeaderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
  [sectionHeaderView addSubview:sectionHeaderLabel];
  return sectionHeaderView;
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:album];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  PhotoViewController *svc = [[PhotoViewController alloc] init];
  svc.album = album;
  if (self.albumType == AlbumTypeWall) {
    svc.sectionNameKeyPathForFetchedResultsController = @"timestamp";
  }
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
  [cell loadPhoto];
  
  return cell;
}

- (void)loadImagesForOnScreenRows {
  [super loadImagesForOnScreenRows];
  
  //  for (id cell in _visibleCells) {
  //    [cell loadPhoto];
  //  }
}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  NSPredicate *predicate = nil;
  NSPredicate *compoundPredicate = nil;
  
  //  predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  
  if ([scope isEqualToString:@"Author"]) {
    // search friend's full name
    predicate = [NSPredicate predicateWithFormat:@"fromName CONTAINS[cd] %@", searchText, searchText];
  } else {
    // default to album name
    predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  }
  
  compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:_predicate, predicate, nil]];
  
  [self.fetchedResultsController.fetchRequest setPredicate:compoundPredicate];
  NSString *cacheName = [NSString stringWithFormat:@"%@_frc_cache", [self description]];
  [NSFetchedResultsController deleteCacheWithName:cacheName];
  [self executeFetch];
//  [_tableView reloadData];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  NSString *fetchTemplate = nil;
  NSDictionary *substitutionVariables = nil;
  NSString *facebookId = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"];
  switch (self.albumType) {
    case AlbumTypeMe:
      fetchTemplate = @"getMyAlbums";
      substitutionVariables = [NSDictionary dictionaryWithObject:facebookId forKey:@"desiredFromId"];
      break;
    case AlbumTypeFriends:
      fetchTemplate = @"getFriendsAlbums";
      substitutionVariables = [NSDictionary dictionaryWithObject:facebookId forKey:@"desiredFromId"];
      break;
    case AlbumTypeWall:
      fetchTemplate = @"getWallAlbums";
      substitutionVariables = [NSDictionary dictionary];
      break;
    case AlbumTypeMobile:
      fetchTemplate = @"getMobileAlbums";
      substitutionVariables = [NSDictionary dictionary];
      break;
    case AlbumTypeProfile:
      fetchTemplate = @"getProfileAlbums";
      substitutionVariables = [NSDictionary dictionary];
      break;
    default:
      break;
  }
  
  return [[AlbumDataCenter defaultCenter] fetchAlbumsWithTemplate:fetchTemplate andSubstitutionVariables:substitutionVariables andLimit:_limit andOffset:_offset];
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
  [super dealloc];
}

@end

//
//  MessageViewController.m
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"
#import "PodDataCenter.h"
#import "MessageDataCenter.h"
#import "Message.h"
#import "Pod.h"
#import "HeaderCell.h"
#import "ComposeViewController.h"
#import "ConfigViewController.h"
#import "PSRollupView.h"
#import "ConfigDataCenter.h"

// Cells
#import "MessageCell.h"
#import "PhotoCell.h"
#import "MapCell.h"

@implementation MessageViewController

@synthesize pod = _pod;

- (id)init {
  self = [super init];
  if (self) {
    _sectionNameKeyPathForFetchedResultsController = [@"timestamp" retain];
    _headerCellCache = [[NSMutableDictionary alloc] init];
    self.hidesBottomBarWhenPushed = YES;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kReloadMessageController object:nil];
  [[MessageDataCenter defaultCenter] setDelegate:self];
  [[ConfigDataCenter defaultCenter] setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadMessageController object:nil];
  [[MessageDataCenter defaultCenter] setDelegate:nil];
  [[ConfigDataCenter defaultCenter] setDelegate:nil];
}

- (void)loadView {
  [super loadView];
  
  [self resetFetchedResultsController];
  
  // Title and Buttons
  _navTitleLabel.text = _pod.name;
  
  [self addBackButton];
  [self addButtonWithTitle:@"Settings" andSelector:@selector(config) isLeft:NO type:PSBarButtonTypeNormal];
  
  // Table
  CGRect tableFrame = self.view.bounds;
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  // Search
//  [self setupSearchDisplayControllerWithScopeButtonTitles:nil andPlaceholder:@"Search..."];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  [self setupFooter];
  
//  [self setupLoadMoreView];
  
  [self executeFetch:YES];
  
//  _album.lastViewed = [NSDate date];
//  [PSCoreDataStack saveInContext:[_album managedObjectContext]];
  
  [[ConfigDataCenter defaultCenter] getMembersForPodId:_pod.id];
  
  // Get new from server
  [self reloadCardController];
}

- (void)setupPodMembersWithUserInfo:(NSDictionary *)userInfo {
  NSArray *podMembers = [userInfo objectForKey:@"data"];
  NSArray *memberPictures = [podMembers valueForKey:@"picture_url"];
  [_podMembersView setHeaderText:[NSString stringWithFormat:@"There are %d friends are in this pod.", [memberPictures count]]];
  [_podMembersView setPictureURLArray:memberPictures];
  [_podMembersView layoutIfNeeded];
  self.tableView.tableHeaderView = _podMembersView;
}

- (void)setupTableHeader {
  // Pod Members
  
  // Create Rollup
  _podMembersView = [[PSRollupView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 0)];
  [_podMembersView setBackgroundImage:[UIImage stretchableImageNamed:@"bg-darkgray-320x44.png" withLeftCapWidth:0 topCapWidth:0]];
}

- (void)setupTableFooter {
  UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_footer_background.png"]];
  _tableView.tableFooterView = footerImage;
  [footerImage release];
}

- (void)setupFooter {
  UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
  
  // Setup the fake image view
  PSURLCacheImageView *profileImage = [[PSURLCacheImageView alloc] initWithFrame:CGRectMake(10, 7, 30, 30)];
  profileImage.urlPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookPictureUrl"];
  [profileImage loadImageAndDownload:YES];
  profileImage.layer.cornerRadius = 5.0;
  profileImage.layer.masksToBounds = YES;
  [footerView addSubview:profileImage];
  [profileImage release];
  
  // Setup the fake message button
  UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(45, 7, self.view.width - 55, 30)];
  messageButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  messageButton.titleLabel.font = [UIFont systemFontOfSize:14];
  [messageButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
  [messageButton setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
  [messageButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  [messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  [messageButton setTitle:@"Send a message..." forState:UIControlStateNormal];
  [messageButton setBackgroundImage:[[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
  [messageButton addTarget:self action:@selector(newMessage) forControlEvents:UIControlEventTouchUpInside];
  [footerView addSubview:messageButton];
  [messageButton release];
  
  footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar_bg.png"]];
  
  [self setupFooterWithView:footerView];
}

- (void)reloadCardController {
  [super reloadCardController];
  
//  [[MessageDataCenter defaultCenter] getMessagesFromFixtures];
  [[MessageDataCenter defaultCenter] getMessagesForPodId:_pod.id];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  if ([[request.userInfo objectForKey:@"action"] isEqualToString:@"members"]) {
    [self setupPodMembersWithUserInfo:response];
  }
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self dataSourceDidLoad];
}

#pragma mark - Compose
- (void)newMessage {
  ComposeViewController *cvc = [[ComposeViewController alloc] init];
  cvc.delegate = self;
  cvc.podId = _pod.id;
  cvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self presentModalViewController:cvc animated:YES];
  [cvc release];
}

- (void)composeDidSendWithUserInfo:(NSDictionary *)userInfo {
  // Write a local copy to core data from composed message
  [[MessageDataCenter defaultCenter] serializeComposedMessageWithUserInfo:userInfo];
  
  // Update pod with most recent message locally
  [[PodDataCenter defaultCenter] updatePod:_pod withUserInfo:userInfo];
}

#pragma mark - Config
- (void)config {
  ConfigViewController *cvc = [[ConfigViewController alloc] init];
  cvc.pod = _pod;
  UINavigationController *cnc = [[UINavigationController alloc] initWithRootViewController:cvc];
  [self presentModalViewController:cnc animated:YES];
  [cvc release];
  [cnc release];
}

#pragma mark - TableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  Message *message = [[self.fetchedResultsController fetchedObjects] objectAtIndex:section];
  
  HeaderCell *headerCell = [[[HeaderCell alloc] initWithFrame:CGRectMake(0, 0, 320, [HeaderCell headerHeight])] autorelease];
  [headerCell fillCellWithObject:message];
  [_headerCellCache setObject:headerCell forKey:[NSString stringWithFormat:@"%d", section]];
  return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return [HeaderCell headerHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
  if (message.photoUrl) {
    return [PhotoCell rowHeightForObject:message forInterfaceOrientation:[self interfaceOrientation]];
  } else {
    return [MapCell rowHeightForObject:message forInterfaceOrientation:[self interfaceOrientation]];
  }
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:message];
  [cell layoutIfNeeded];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];

  id cell = nil;
  if (message.photoUrl) {
    cell = [self cellForType:MessageCellTypePhoto withObject:message];
  } else {
    cell = [self cellForType:MessageCellTypeMap withObject:message];
  }
  return cell;
}

- (id)cellForType:(MessageCellType)cellType withObject:(id)object {
  id cell = nil;
  NSString *reuseIdentifier = nil;
  
  switch (cellType) {
    case MessageCellTypePhoto:
      reuseIdentifier = [PhotoCell reuseIdentifier];
      cell = (PhotoCell *)[_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
      if(cell == nil) { 
        cell = [[[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
      }
      [cell fillCellWithObject:object];
      [cell loadPhoto];
      break;
    case MessageCellTypeMap:
      reuseIdentifier = [MapCell reuseIdentifier];
      cell = (MapCell *)[_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
      if(cell == nil) { 
        cell = [[[MapCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
      }
      [cell fillCellWithObject:object];
      break;
    default:
      // MessageCellTypeDefault
      reuseIdentifier = [MessageCell reuseIdentifier];
      cell = (MessageCell *)[_tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
      if(cell == nil) { 
        cell = [[[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
      }
      [cell fillCellWithObject:object];
      break;
  }
  return cell;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//  PhotoCell *cell = (PhotoCell *)[tableView cellForRowAtIndexPath:indexPath];
//  [self zoomPhotoForCell:cell atIndexPath:indexPath];
//}
//
//- (void)zoomPhotoForCell:(PhotoCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//  if (!_zoomView) {
//    _zoomView = [[PSZoomView alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] bounds]];
//  }
//  
//  Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
//  _zoomView.photo = photo;
//  _zoomView.zoomImageView.image = cell.photoView.image;
//  _zoomView.zoomImageView.frame = [cell convertRect:cell.photoView.frame toView:nil];
//  _zoomView.oldImageFrame = [cell convertRect:cell.photoView.frame toView:nil];
//  _zoomView.oldCaptionFrame = [cell convertRect:cell.captionLabel.frame toView:nil];
//  _zoomView.caption = [[cell.captionLabel.text copy] autorelease];
//  [_zoomView showZoom];
//}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)delayedFilterContentWithTimer:(NSTimer *)timer {
  NSDictionary *userInfo = [timer userInfo];
  NSString *searchText = [userInfo objectForKey:@"searchText"];
//  NSString *scope = [userInfo objectForKey:@"scope"];
  NSMutableArray *subpredicates = [NSMutableArray arrayWithCapacity:1];
  
  NSArray *searchTerms = [[searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" -,/\\+_"]];
  
  for (NSString *searchTerm in searchTerms) {
    NSString *searchValue = [NSString stringWithFormat:@"%@", searchTerm];
    [subpredicates addObject:[NSPredicate predicateWithFormat:@"message CONTAINS[cd] %@", searchValue]];
  }
  
  if (_searchPredicate) {
    RELEASE_SAFELY(_searchPredicate);
  }
  _searchPredicate = [[NSCompoundPredicate andPredicateWithSubpredicates:subpredicates] retain];
  
  [self executeFetch:YES];
}
#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  NSString *sortKey = @"timestamp";
  NSString *fetchTemplate = @"getMessagesForPod";
  NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:NO]];
  NSDictionary *substitutionVariables = [NSDictionary dictionaryWithObject:_pod.id forKey:@"desiredPodId"];
  
  NSFetchRequest *fetchRequest = [[PSCoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:fetchTemplate substitutionVariables:substitutionVariables];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setFetchBatchSize:10];
  
  return fetchRequest;
}

- (void)dealloc {
  RELEASE_SAFELY(_podMembersView);
  RELEASE_SAFELY(_headerCellCache);
  [super dealloc];
}

@end

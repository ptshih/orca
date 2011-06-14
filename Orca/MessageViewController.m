//
//  MessageViewController.m
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageDataCenter.h"
#import "Message.h"
#import "Pod.h"
#import "MessageCell.h"
#import "ComposeViewController.h"

@implementation MessageViewController

@synthesize pod = _pod;

- (id)init {
  self = [super init];
  if (self) {
    _sectionNameKeyPathForFetchedResultsController = nil;
    _headerCellCache = [[NSMutableDictionary alloc] init];
    self.hidesBottomBarWhenPushed = YES;
    [[MessageDataCenter defaultCenter] setDelegate:self];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kReloadMessageController object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadMessageController object:nil];
}

- (void)loadView {
  [super loadView];
  
  [self resetFetchedResultsController];
  
  // Title and Buttons
  _navTitleLabel.text = _pod.name;
  
  [self addBackButton];
//  [self addButtonWithTitle:@"Favorite" andSelector:@selector(favorite) isLeft:NO];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  // Search
  [self setupSearchDisplayControllerWithScopeButtonTitles:nil andPlaceholder:@"Search..."];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  [self setupTableFooter];
  
  [self setupFooterView];
  
//  [self setupLoadMoreView];
  
  [self executeFetch:YES];
  
//  _album.lastViewed = [NSDate date];
//  [PSCoreDataStack saveInContext:[_album managedObjectContext]];
  
  // Get new from server
  [self reloadCardController];
}

- (void)setupFooterView {
  [super setupFooterView];
  
  // Setup the fake image view
  PSURLCacheImageView *profileImage = [[PSURLCacheImageView alloc] initWithFrame:CGRectMake(10, 7, 30, 30)];
  profileImage.urlPath = [[NSUserDefaults standardUserDefaults] stringForKey:@"facebookPictureUrl"];
  [profileImage loadImageAndDownload:YES];
  profileImage.layer.cornerRadius = 5.0;
  profileImage.layer.masksToBounds = YES;
  [_footerView addSubview:profileImage];
  [profileImage release];
  
  // Setup the fake message button
  UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(45, 7, 265, 30)];
  messageButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  messageButton.titleLabel.font = [UIFont systemFontOfSize:14];
  [messageButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
  [messageButton setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
  [messageButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  [messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  [messageButton setTitle:@"Send a message..." forState:UIControlStateNormal];
  [messageButton setBackgroundImage:[[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
  [messageButton addTarget:self action:@selector(newMessage) forControlEvents:UIControlEventTouchUpInside];
  [_footerView addSubview:messageButton];
  [messageButton release];
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
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark Compose
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
}

#pragma mark -
#pragma mark TableView
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//  Photo *photo = [[self.fetchedResultsController fetchedObjects] objectAtIndex:section];
//  
//  HeaderCell *headerCell = [[[HeaderCell alloc] initWithFrame:CGRectMake(0, 0, 320, 26)] autorelease];
//  [headerCell fillCellWithObject:photo];
//  //  [headerCell loadImage];
//  [_headerCellCache setObject:headerCell forKey:[NSString stringWithFormat:@"%d", section]];
//  return headerCell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//  return 26.0;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [MessageCell rowHeightForObject:message forInterfaceOrientation:[self interfaceOrientation]];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:message];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  MessageCell *cell = nil;
  NSString *reuseIdentifier = [MessageCell reuseIdentifier];
  
  cell = (MessageCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  [self tableView:tableView configureCell:cell atIndexPath:indexPath];
  
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
  [(MessageCell *)cell loadImage];
}


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
  [[MessageDataCenter defaultCenter] setDelegate:nil];
  RELEASE_SAFELY(_headerCellCache);
  [super dealloc];
}

@end

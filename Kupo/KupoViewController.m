//
//  KupoViewController.m
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoViewController.h"
#import "KupoDataCenter.h"
#import "KupoCell.h"
#import "Event.h"
#import "ComposeViewController.h"
#import "DetailViewController.h"
#import "VideoViewController.h"

@implementation KupoViewController

@synthesize event = _event;

- (id)init {
  self = [super init];
  if (self) {
    [[KupoDataCenter defaultCenter] setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kReloadController object:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Nav Title
  _navTitleLabel.text = self.event.name;
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  // Footer
  [self setupFooterView];
  
  // Load More
  [self setupLoadMoreView];
  
  [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"frc_cache_%@", [self class]]];
  
  [self executeFetch];
  [self reloadCardController];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)setupFooterView {
  [super setupFooterView];
  
  // Setup the fake image view
  PSImageView *profileImage = [[PSImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
  profileImage.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [[NSUserDefaults standardUserDefaults] objectForKey:@"facebookId"]];
  [profileImage loadImage];
  profileImage.layer.cornerRadius = 5.0;
  profileImage.layer.masksToBounds = YES;
  [_footerView addSubview:profileImage];
  [profileImage release];
  
  // Setup the fake comment button
  UIButton *commentButton = [[UIButton alloc] initWithFrame:CGRectMake(45, 5, 265, 30)];
  commentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  commentButton.titleLabel.font = [UIFont systemFontOfSize:14];
  [commentButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
  [commentButton setContentEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
  [commentButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
  [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  [commentButton setTitle:@"Write a comment or share a picture..." forState:UIControlStateNormal];
  [commentButton setBackgroundImage:[[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
  [commentButton addTarget:self action:@selector(composeKupo) forControlEvents:UIControlEventTouchUpInside];
  [_footerView addSubview:commentButton];
  [commentButton release];
}
   
- (void)composeKupo {
  ComposeViewController *kcvc = [[ComposeViewController alloc] init];
  kcvc.kupoComposeType = KupoComposeTypeKupo;
  kcvc.eventId = self.event.id;
  UINavigationController *kupoNav = [[UINavigationController alloc] initWithRootViewController:kcvc];
  kupoNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self presentModalViewController:kupoNav animated:YES];
  [kcvc release];
  [kupoNav release];
}

#pragma mark -
#pragma mark TableView
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
  [cell setNeedsDisplay];
  [(KupoCell *)cell loadImage];
  [(KupoCell *)cell loadPhoto];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Kupo *kupo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:kupo];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Kupo *kupo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [KupoCell rowHeightForObject:kupo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Kupo *kupo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  if ([kupo.hasPhoto boolValue]) {
    
    if ([kupo.hasVideo boolValue]) {
      VideoViewController *vvc = [[VideoViewController alloc] init];
      vvc.kupo = kupo;
      [self.navigationController pushViewController:vvc animated:YES];
      [vvc release];
    } else {    
      DetailViewController *dvc = [[DetailViewController alloc] init];
      dvc.kupo = kupo;
      [self.navigationController pushViewController:dvc animated:YES];
      [dvc release];
    }
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  KupoCell *cell = nil;
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell_%d", [self class], indexPath.section];
  
  cell = (KupoCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[KupoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  [self tableView:tableView configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

#pragma mark -
#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
  
  // Get since date
  NSDate *sinceDate = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"since.kupos.%@", self.event.id]];
  [[KupoDataCenter defaultCenter] getKuposForEventWithEventId:self.event.id andSince:sinceDate];
  
//  [[KupoDataCenter defaultCenter] loadKuposFromFixture];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self dataSourceDidLoad];
  
  [self executeFetch];
  
  if ([self.fetchedResultsController.fetchedObjects count] > 0) {
    // Set since and until date
    Kupo *firstKupo = [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
    Kupo *lastKupo = [[self.fetchedResultsController fetchedObjects] lastObject];
    NSDate *sinceDate = firstKupo.timestamp;
    NSDate *untilDate = lastKupo.timestamp;
    [[NSUserDefaults standardUserDefaults] setValue:sinceDate forKey:[NSString stringWithFormat:@"since.kupos.%@", self.event.id]];
    [[NSUserDefaults standardUserDefaults] setValue:untilDate forKey:[NSString stringWithFormat:@"until.kupos.%@", self.event.id]];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark LoadMore
- (void)loadMore {
  [super loadMore];
  
  // get until date
  NSDate *untilDate = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"until.kupos.%@", self.event.id]];
  [[KupoDataCenter defaultCenter] loadMoreKuposForEventWithEventId:self.event.id andUntil:untilDate];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [[KupoDataCenter defaultCenter] getKuposFetchRequestWithEventId:self.event.id];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadController object:nil];
  [[KupoDataCenter defaultCenter] setDelegate:nil];
  RELEASE_SAFELY(_event);
  [super dealloc];
}

@end
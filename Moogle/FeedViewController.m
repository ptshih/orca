//
//  FeedViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedViewController.h"
#import "FeedDataCenter.h"
#import "FeedCell.h"
#import "Pod.h"
#import "KupoComposeViewController.h"

@implementation FeedViewController

@synthesize pod = _pod;

- (id)init {
  self = [super init];
  if (self) {
    _feedDataCenter = [[FeedDataCenter alloc] init];
    _feedDataCenter.delegate = self;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Add Back Bar Button  
  UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
  back.frame = CGRectMake(0, 0, 60, 32);
  [back setTitle:@"Back" forState:UIControlStateNormal];
  [back setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
  [back setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
  back.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
  UIImage *backImage = [[UIImage imageNamed:@"navigationbar_button_back.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];  
  [back setBackgroundImage:backImage forState:UIControlStateNormal];  
  [back addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *backButton = [[[UIBarButtonItem alloc] initWithCustomView:back] autorelease];
  self.navigationItem.leftBarButtonItem = backButton;
  
  // Nav Title
  _navTitleLabel.text = self.pod.name;
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  // Footer
  [self setupFooterView];
  
  [self reloadCardController];
}

- (void)setupFooterView {
  [super setupFooterView];
  
  // Setup the fake image view
  MoogleImageView *profileImage = [[MoogleImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
  profileImage.urlPath = @"http://profile.ak.fbcdn.net/hprofile-ak-snc4/174453_548430564_3413707_q.jpg";
  [profileImage loadImage];
  profileImage.layer.cornerRadius = 5.0;
  profileImage.layer.masksToBounds = YES;
  [_footerView addSubview:profileImage];
  [profileImage release];
  
  // Setup the fake comment button
  UIButton *commentButton = [[UIButton alloc] initWithFrame:CGRectMake(45, 5, 265, 30)];
  commentButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [commentButton setBackgroundImage:[[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal];
  [commentButton addTarget:self action:@selector(composeKupo) forControlEvents:UIControlEventTouchUpInside];
  [_footerView addSubview:commentButton];
  [commentButton release];
}
   
- (void)composeKupo {
  KupoComposeViewController *kcvc = [[KupoComposeViewController alloc] init];
  kcvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self presentModalViewController:kcvc animated:YES];
  [kcvc release];
}

#pragma mark -
#pragma mark TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [FeedCell rowHeightForObject:feed];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FeedCell *cell = nil;
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell_%d", [self class], indexPath.section];
  
  cell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:feed];
  
  return cell;
}

#pragma mark -
#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
  [_feedDataCenter loadFeedsFromFixture];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark MoogleDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self resetFetchedResultsController];
  [self.tableView reloadData];
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  [self resetFetchedResultsController];
  [self.tableView reloadData];
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_feedDataCenter getFeedsFetchRequestForPod:self.pod.id];
}

- (void)dealloc {
  RELEASE_SAFELY(_feedDataCenter);
  RELEASE_SAFELY(_pod);
  [super dealloc];
}

@end
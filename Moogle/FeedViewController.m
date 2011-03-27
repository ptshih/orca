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
  back.titleLabel.font = [UIFont boldSystemFontOfSize:11];
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
}

- (void)setupFooterView {
  [super setupFooterView];
  
  _kupoComposeViewController = [[KupoComposeViewController alloc] init];
  _kupoComposeViewController.parentView = self.view;
  _kupoComposeViewController.view.frame = _footerView.bounds;
  [_footerView addSubview:_kupoComposeViewController.view];
}
   
- (void)composeKupo {
}

#pragma mark -
#pragma mark TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [FeedCell variableRowHeightWithFeed:feed];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  FeedCell *cell = nil;
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell_%d", [self class], indexPath.section];
  
  cell = (FeedCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[FeedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  Feed *feed = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithFeed:feed];
  
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
  RELEASE_SAFELY(_kupoComposeViewController);
  [super dealloc];
}

@end
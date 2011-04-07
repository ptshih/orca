//
//  KupoViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoViewController.h"
#import "KupoDataCenter.h"
#import "KupoCell.h"
#import "Place.h"
#import "ComposeViewController.h"
#import "DetailViewController.h"
#import "VideoViewController.h"

@implementation KupoViewController

@synthesize place = _place;

- (id)init {
  self = [super init];
  if (self) {
    [[KupoDataCenter defaultCenter] setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kComposeDidFinish object:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Nav Title
  _navTitleLabel.text = self.place.name;
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  // Footer
  [self setupFooterView];
  
  [NSFetchedResultsController deleteCacheWithName:[NSString stringWithFormat:@"frc_cache_%@", [self class]]];
  [self reloadCardController];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)setupFooterView {
  [super setupFooterView];
  
  // Setup the fake image view
  MoogleImageView *profileImage = [[MoogleImageView alloc] initWithFrame:CGRectMake(10, 5, 30, 30)];
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
  kcvc.moogleComposeType = MoogleComposeTypeKupo;
  kcvc.placeId = self.place.placeId;
  UINavigationController *kupoNav = [[UINavigationController alloc] initWithRootViewController:kcvc];
  kupoNav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  [self presentModalViewController:kupoNav animated:YES];
  [kcvc release];
  [kupoNav release];
}

#pragma mark -
#pragma mark TableView
- (void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Kupo *kupo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:kupo];
  [cell loadImage];
  [cell setNeedsLayout];
  [cell setNeedsDisplay];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Kupo *kupo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [KupoCell rowHeightForObject:kupo];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  Kupo *kupo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  if ([kupo.hasPhoto boolValue]) {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
  
  Kupo *kupo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:kupo];
  [cell loadImage];
  [cell loadPhoto];
  [cell setNeedsLayout];
  [cell setNeedsDisplay];
  return cell;
}

#pragma mark -
#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
  
  [[KupoDataCenter defaultCenter] getKuposForPlaceWithPlaceId:self.place.placeId];
//  [[KupoDataCenter defaultCenter] loadKuposFromFixture];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark MoogleDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [self resetFetchedResultsController];
  [self dataSourceDidLoad];
  
  // Mark isRead state
  NSManagedObjectContext *context = [LICoreDataStack managedObjectContext];
  self.place.isRead = [NSNumber numberWithBool:YES];
  
  NSError *error = nil;
  if ([context hasChanges]) {
    if (![context save:&error]) {
      abort(); // NOTE: DO NOT SHIP
    }
  }
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  [self resetFetchedResultsController];
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [[KupoDataCenter defaultCenter] getKuposFetchRequestWithPlaceId:self.place.placeId];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kComposeDidFinish object:nil];
  [[KupoDataCenter defaultCenter] setDelegate:nil];
  RELEASE_SAFELY(_place);
  [super dealloc];
}

@end
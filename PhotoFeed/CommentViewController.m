//
//  CommentViewController.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentDataCenter.h"
#import "Comment.h"
#import "Photo.h"

@implementation CommentViewController

@synthesize photo = _photo;

- (id)init {
  self = [super init];
  if (self) {
    _commentDataCenter = [[CommentDataCenter alloc] init];
    _commentDataCenter.delegate = self;
    _limit = 999;
    self.hidesBottomBarWhenPushed = YES;
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

- (void)loadView {
  [super loadView];
  
  // Title and Buttons
  _navTitleLabel.text = _photo.name;
  
  [self addBackButton];
  [self addButtonWithTitle:@"New" andSelector:@selector(newComment) isLeft:NO];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  [self resetFetchedResultsController];
  [self executeFetch];
  [self updateState];
  
  // Get new from server
  [self reloadCardController];
}

- (void)reloadCardController {
  [super reloadCardController];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  //  NSLog(@"DC finish with response: %@", response);
  //  [self executeFetch];
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark Compose
- (void)newComment {
  //  CameraViewController *cvc = [[CameraViewController alloc] init];
  //  UINavigationController *cnc = [[UINavigationController alloc] initWithRootViewController:cvc];
  //  [self presentModalViewController:cnc animated:YES];
  //  [cvc autorelease];
  //  [cnc autorelease];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_commentDataCenter fetchCommentsForPhoto:_photo];
}

- (void)dealloc {
  _commentDataCenter.delegate = nil;
  RELEASE_SAFELY(_commentDataCenter);
  [super dealloc];
}

@end

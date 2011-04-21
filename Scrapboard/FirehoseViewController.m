//
//  FirehoseViewController.m
//  Scrapboard
//
//  Created by Peter Shih on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirehoseViewController.h"
#import "FirehoseDataCenter.h"

@implementation FirehoseViewController

- (id)init {
  self = [super init];
  if (self) {
    [[FirehoseDataCenter defaultCenter] setDelegate:self];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Nav Title
  _navTitleLabel.text = @"All Scrapboards";
}

#pragma mark -
#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
  
  // Get since date
  NSDate *sinceDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"since.events.firehose"];
  [[FirehoseDataCenter defaultCenter] getEventsWithSince:sinceDate];
  //  [[EventDataCenter defaultCenter] loadEventsFromFixture];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  [super dataCenterDidFinish:operation];
  
  if ([self.fetchedResultsController.fetchedObjects count] > 0) {
    // Set since and until date
    Event *firstEvent = [[self.fetchedResultsController fetchedObjects] objectAtIndex:0];
    Event *lastEvent = [[self.fetchedResultsController fetchedObjects] lastObject];
    NSDate *sinceDate = firstEvent.timestamp;
    NSDate *untilDate = lastEvent.timestamp;
    [[NSUserDefaults standardUserDefaults] setValue:sinceDate forKey:@"since.events.firehose"];
    [[NSUserDefaults standardUserDefaults] setValue:untilDate forKey:@"until.events.firehose"];
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
  NSDate *untilDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"until.events.firehose"];
  [[FirehoseDataCenter defaultCenter] loadMoreEventsWithUntil:untilDate];
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [[FirehoseDataCenter defaultCenter] getEventsFetchRequest];
}

#pragma mark -
#pragma mark Memory Management
- (void)dealloc {
  [[FirehoseDataCenter defaultCenter] setDelegate:nil];
  [super dealloc];
}

@end

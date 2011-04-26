//
//  AlbumViewController.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumViewController.h"
#import "AlbumDataCenter.h"

@implementation AlbumViewController

- (id)init {
  self = [super init];
  if (self) {
    _albumDataCenter = [[AlbumDataCenter alloc] init];
    _albumDataCenter.delegate = self;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [_albumDataCenter getAlbums];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  NSLog(@"DC finish with response: %@", response);
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  
}

- (void)dealloc {
  RELEASE_SAFELY(_albumDataCenter);
  [super dealloc];
}
@end

//
//  MeDataCenter.m
//  Scrapboard
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MeDataCenter.h"

static MeDataCenter *_defaultCenter = nil;

@implementation MeDataCenter

#pragma mark -
#pragma mark Shared Instance
+ (id)defaultCenter {
  @synchronized(self) {
    if (_defaultCenter == nil) {
      _defaultCenter = [[self alloc] init];
    }
    return _defaultCenter;
  }
}

- (void)requestMe {
  NSURL *sessionUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/kupo/me", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [self sendOperationWithURL:sessionUrl andMethod:GET andHeaders:nil andParams:params];
}

- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFailedWithOperation:operation];
}

@end

//
//  MeDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MeDataCenter.h"


@implementation MeDataCenter

- (void)requestMe {
  NSURL *sessionUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/moogle/me", MOOGLE_BASE_URL]];
  
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

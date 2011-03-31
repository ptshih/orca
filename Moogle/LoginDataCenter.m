//
//  LoginDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginDataCenter.h"


@implementation LoginDataCenter

- (void)startSession {
  NSURL *sessionUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/moogle/session", MOOGLE_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [self sendOperationWithURL:sessionUrl andMethod:POST andHeaders:nil andParams:params];
}

- (void)startRegister {
  NSURL *registerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/moogle/register", MOOGLE_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [self sendOperationWithURL:registerUrl andMethod:POST andHeaders:nil andParams:params];
}

- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFailedWithOperation:operation];
}

@end
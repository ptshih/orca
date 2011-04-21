//
//  LoginDataCenter.m
//  Scrapboard
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginDataCenter.h"

static LoginDataCenter *_defaultCenter = nil;

@implementation LoginDataCenter

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

- (void)startSession {
  NSURL *sessionUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/session", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [self sendOperationWithURL:sessionUrl andMethod:POST andHeaders:nil andParams:params];
}

- (void)startRegister {
  NSURL *registerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/register", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"] forKey:@"facebook_access_token"];
  
  [self sendOperationWithURL:registerUrl andMethod:POST andHeaders:nil andParams:params];
}

- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFailedWithOperation:operation];
}

@end
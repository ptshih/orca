//
//  LoginDataCenter.m
//  PhotoFeed
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginDataCenter.h"

@implementation LoginDataCenter

- (void)startSession {
  NSURL *sessionUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/session", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [self sendRequestWithURL:sessionUrl andMethod:POST andHeaders:nil andParams:params andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"session", @"login", nil]];
}

- (void)startRegister {
  NSURL *registerUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/login/register", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"] forKey:@"facebook_access_token"];
  
  [self sendRequestWithURL:registerUrl andMethod:POST andHeaders:nil andParams:params andUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"register", @"login", nil]];
}

@end
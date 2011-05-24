//
//  LoginDataCenter.m
//  PhotoFeed
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginDataCenter.h"

static LoginDataCenter *_defaultCenter = nil;

@implementation LoginDataCenter

+ (LoginDataCenter *)defaultCenter {
  if (!_defaultCenter) {
    _defaultCenter = [[self alloc] init];
  }
  return _defaultCenter;
}

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

- (void)getFacebookId {
  NSURL *meUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/me", FB_GRAPH]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:@"id,name" forKey:@"fields"];
  
  [self sendRequestWithURL:meUrl andMethod:GET andHeaders:nil andParams:params andUserInfo:nil];
}

#pragma mark -
#pragma mark Request finished
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request withResponseData:(NSData *)responseData {
  id response = [responseData JSONValue];
  
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFinish:withResponse:)]) {
    [_delegate performSelector:@selector(dataCenterDidFinish:withResponse:) withObject:request withObject:response];
  }
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFail:withError:)]) {
    [_delegate performSelector:@selector(dataCenterDidFail:withError:) withObject:request withObject:error];
  }
}

@end
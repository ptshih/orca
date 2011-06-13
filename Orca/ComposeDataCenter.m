//
//  ComposeDataCenter.m
//  Orca
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeDataCenter.h"

@implementation ComposeDataCenter

+ (ComposeDataCenter *)defaultCenter {
  static ComposeDataCenter *defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (void)sendMessage:(NSString *)message andSequence:(NSString *)sequence forPodId:(NSString *)podId {
  NSURL *composeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"messages"]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:podId forKey:@"podId"];
  [params setValue:message forKey:@"message"];
  [params setValue:sequence forKey:@"sequence"];
  
  [self sendRequestWithURL:composeURL andMethod:POST andHeaders:nil andParams:params andUserInfo:nil];
}

- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadController object:nil];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadController object:nil];
}

@end

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

- (void)sendMessage:(NSString *)message andSequence:(NSString *)sequence forPodId:(NSString *)podId hasPhoto:(BOOL)hasPhoto {
  NSURL *composeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pods/%@/messages/create", API_BASE_URL, podId]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:message forKey:@"message"];
  [params setValue:sequence forKey:@"sequence"];
  [params setValue:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:hasPhoto]] forKey:@"has_photo"];
  
  VLog(@"Sending a new message: %@ with sequence: %@", message, sequence);
  
  [self sendRequestWithURL:composeURL andMethod:POST andHeaders:nil andParams:params andUserInfo:nil];
}

- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
}

@end

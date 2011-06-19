//
//  ConfigDataCenter.m
//  Orca
//
//  Created by Peter Shih on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigDataCenter.h"


@implementation ConfigDataCenter

+ (ConfigDataCenter *)defaultCenter {
  static ConfigDataCenter *defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

#pragma mark - API Calls
- (void)getMembersForPodId:(NSString *)podId {
  NSURL *membersUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pods/%@/members", API_BASE_URL, podId]];
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"members" forKey:@"action"];
  [self sendRequestWithURL:membersUrl andMethod:GET andHeaders:nil andParams:nil andUserInfo:userInfo];
}

- (void)leavePodForPodId:(NSString *)podId {
  
}

- (void)mutePodForPodId:(NSString *)podId forDuration:(NSInteger)duration {
  NSURL *muteUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pods/%@/mute/%d", API_BASE_URL, podId, duration]];
  
  NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"mute" forKey:@"action"];
  [self sendRequestWithURL:muteUrl andMethod:GET andHeaders:nil andParams:nil andUserInfo:userInfo];
}

#pragma mark - Data Center
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  id response = [[[request responseData] JSONValue] valueForKey:@"data"];
  
  // Inform Delegate if all responses are parsed
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFinish:withResponse:)]) {
    [_delegate performSelector:@selector(dataCenterDidFinish:withResponse:) withObject:request withObject:response];
  }
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  DLog(@"Request failed with error: %@", [[request error] localizedDescription]);
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFail:withError:)]) {
    [_delegate performSelector:@selector(dataCenterDidFail:withError:) withObject:request withObject:[request error]];
  }
}

- (void)dealloc {
  [super dealloc];
}

@end

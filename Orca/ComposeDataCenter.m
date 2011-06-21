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

- (void)sendMessage:(NSString *)message andSequence:(NSString *)sequence forPodId:(NSString *)podId withPhotoData:(NSData *)photoData andUserInfo:(NSDictionary *)userInfo {
  VLog(@"Sending a new message: %@ with sequence: %@", message, sequence);
  
  NSURL *composeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pods/%@/messages/create", API_BASE_URL, podId]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:message forKey:@"message"];
  [params setValue:sequence forKey:@"sequence"];
  
  NSDictionary *file = nil;
  if (photoData) {  
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", sequence];
    
    file = [NSDictionary dictionaryWithObjectsAndKeys:photoData, @"fileData", fileName, @"fileName", @"image/jpeg", @"fileContentType", @"photo", @"fileKey", nil];
    
    [params setValue:[userInfo objectForKey:@"photoWidth"] forKey:@"photo_width"];
    [params setValue:[userInfo objectForKey:@"photoHeight"] forKey:@"photo_height"];
    [params setValue:[userInfo objectForKey:@"photoUrl"] forKey:@"photo_url"];
  }
  
  [self sendFormRequestWithURL:composeURL andHeaders:nil andParams:params andFile:file andUserInfo:nil];
  
//  [params setValue:[NSString stringWithFormat:@"%@", [NSNumber numberWithBool:hasPhoto]] forKey:@"has_photo"];
  
  
//  [self sendRequestWithURL:composeURL andMethod:POST andHeaders:nil andParams:params andUserInfo:nil];
}

- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
}

@end

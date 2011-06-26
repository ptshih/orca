//
//  ComposeDataCenter.m
//  Orca
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeDataCenter.h"
#import "PodDataCenter.h"
#import "MessageDataCenter.h"

@implementation ComposeDataCenter

+ (ComposeDataCenter *)defaultCenter {
  static ComposeDataCenter *defaultCenter = nil;
  if (!defaultCenter) {
    defaultCenter = [[self alloc] init];
  }
  return defaultCenter;
}

- (void)sendMessage:(NSString *)message forPodId:(NSString *)podId withSequence:(NSString *)sequence andMessageType:(NSString *)messageType andUserInfo:(NSDictionary *)userInfo {
  [self sendMessage:message forPodId:podId withSequence:sequence andMessageType:messageType andAttachmentData:nil andUserInfo:userInfo];
}

- (void)sendMessage:(NSString *)message forPodId:(NSString *)podId withSequence:(NSString *)sequence andMessageType:(NSString *)messageType andAttachmentData:(NSData *)attachmentData andUserInfo:(NSDictionary *)userInfo {
  VLog(@"Sending a new message (attachment): %@ with sequence: %@", message, sequence);
  
  NSURL *composeURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/pods/%@/messages/create", API_BASE_URL, podId]];
  
  // Set Params
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:sequence forKey:@"sequence"];
  [params setValue:messageType forKey:@"message_type"];
  
  // Set Metadata
  NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
  [metadata setValue:message forKey:@"message"];
  
  if (attachmentData) {  
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", sequence];
    
//    NSDictionary *file = nil;
//    file = [NSDictionary dictionaryWithObjectsAndKeys:attachmentData, @"fileData", fileName, @"fileName", @"image/jpeg", @"fileContentType", @"photo", @"fileKey", nil];
    
    [metadata setValue:[userInfo objectForKey:@"photoWidth"] forKey:@"photoWidth"];
    [metadata setValue:[userInfo objectForKey:@"photoHeight"] forKey:@"photoHeight"];
    [metadata setValue:[userInfo objectForKey:@"photoUrl"] forKey:@"photoUrl"];
    
    // Send the S3 request
    [self sendS3RequestWithData:attachmentData forBucket:S3_BUCKET forKey:fileName andUserInfo:nil];
  }
  
  NSString *metadataJSON = [metadata JSONRepresentation];
  [params setValue:metadataJSON forKey:@"metadata"];
  
  // Send a request to orca server
  [self sendRequestWithURL:composeURL andMethod:POST andHeaders:nil andParams:params andUserInfo:nil];
  
  // We should create a local copy of this message
  NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
  NSInteger currentTimestampInteger = floor(currentTimestamp);
  NSMutableDictionary *cacheUserInfo = [NSMutableDictionary dictionaryWithCapacity:1];
  [cacheUserInfo setValue:podId forKey:@"pod_id"];
  [cacheUserInfo setValue:sequence forKey:@"sequence"];
  [cacheUserInfo setValue:messageType forKey:@"message_type"];
  [cacheUserInfo setValue:[NSNumber numberWithInteger:currentTimestampInteger] forKey:@"timestamp"];
  [cacheUserInfo setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"] forKey:@"from_id"];
  [cacheUserInfo setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"facebookName"] forKey:@"from_name"];
  [cacheUserInfo setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"facebookPictureUrl"] forKey:@"from_picture_url"];
  [cacheUserInfo setValue:metadataJSON forKey:@"metadata"];
  
  // Write a local copy to core data from composed message
  [[MessageDataCenter defaultCenter] serializeComposedMessageWithUserInfo:cacheUserInfo];
  
  // Update pod with most recent message locally
//  [[PodDataCenter defaultCenter] updatePod:_pod withUserInfo:userInfo];
}

- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
}

@end

//
//  ComposeDataCenter.h
//  Orca
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface ComposeDataCenter : PSDataCenter {

}

+ (ComposeDataCenter *)defaultCenter;

// Send a message
- (void)sendMessage:(NSString *)message forPodId:(NSString *)podId withSequence:(NSString *)sequence andMessageType:(NSString *)messageType andUserInfo:(NSDictionary *)userInfo;

- (void)sendMessage:(NSString *)message forPodId:(NSString *)podId withSequence:(NSString *)sequence andMessageType:(NSString *)messageType andAttachmentData:(NSData *)attachmentData andUserInfo:(NSDictionary *)userInfo;

@end

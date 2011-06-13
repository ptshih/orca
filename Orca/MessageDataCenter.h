//
//  MessageDataCenter.h
//  Orca
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface MessageDataCenter : PSDataCenter {
}

+ (MessageDataCenter *)defaultCenter;

/**
 Get messages from Server
 */
- (void)getMessagesForPodId:(NSString *)podId;
- (void)getMessagesFromFixtures;

/**
 Serialize messages from Server
 */
- (void)serializeMessagesWithRequest:(ASIHTTPRequest *)request;
- (void)serializeMessagesWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context;

/**
 Serialize local copy of a composed message
 */
- (void)serializeComposedMessageWithUserInf:(NSDictionary *)userInfo;

@end

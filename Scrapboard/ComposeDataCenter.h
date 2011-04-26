//
//  ComposeDataCenter.h
//  Scrapboard
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface ComposeDataCenter : PSDataCenter {

}

// Create a new event and the first kupo
- (void)sendEventComposeWithEventName:(NSString *)eventName andEventTag:(NSString *)eventTag andMessage:(NSString *)message andImage:(UIImage *)image andVideo:(NSData *)video;

// Create a new kupo for event
- (void)sendKupoComposeWithEventId:(NSString *)eventId andMessage:(NSString *)message andImage:(UIImage *)image andVideo:(NSData *)video;

@end

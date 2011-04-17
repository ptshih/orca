//
//  ComposeDataCenter.h
//  Kupo
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface ComposeDataCenter : PSDataCenter {

}

- (void)sendKupoComposeWithEventId:(NSString *)eventId andComment:(NSString *)comment andImage:(UIImage *)image andVideo:(NSData *)video;

- (void)sendCheckinComposeWithEventId:(NSString *)eventId andComment:(NSString *)comment andImage:(UIImage *)image andVideo:(NSData *)video;

@end

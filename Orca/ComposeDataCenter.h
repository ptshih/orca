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
- (void)sendMessage:(NSString *)message andSequence:(NSString *)sequence forPodId:(NSString *)podId;

@end

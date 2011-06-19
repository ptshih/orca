//
//  ConfigDataCenter.h
//  Orca
//
//  Created by Peter Shih on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface ConfigDataCenter : PSDataCenter {
  
}

+ (ConfigDataCenter *)defaultCenter;

// Lists

/**
 List of people in a pod
 */
- (void)getMembersForPodId:(NSString *)podId;

// Mutations

/**
 Change name of pod
 */

/**
 Leave pod
 */
- (void)leavePodForPodId:(NSString *)podId;

/**
 Add friend to pod
 */

/**
 Remove friend from pod
 */

/**
 Mute/Unmute pod (optional duration)
 */
- (void)mutePodForPodId:(NSString *)podId forDuration:(NSInteger)duration;

@end

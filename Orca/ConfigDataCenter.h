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

// Mutations

/**
 Change name of pod
 */

/**
 Leave pod
 */

/**
 Add friend to pod
 */

/**
 Remove friend from pod
 */

/**
 Mute pod (optional duration)
 */

/**
 Unmute pod
 */

@end

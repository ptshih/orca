//
//  PodDataCenter.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoogleDataCenter.h"

@interface PodDataCenter : MoogleDataCenter {
}

/**
 Serialize server response into Pod entities
 */
- (void)serializePodsWithDictionary:(NSDictionary *)dictionary;

@end

//
//  PodDataCenter.h
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface PodDataCenter : PSDataCenter {
}

+ (PodDataCenter *)defaultCenter;

/**
 Get pods from Server
 */
- (void)getPods;

/**
 Serialize pods from Server
 */
- (void)serializePodsWithRequest:(ASIHTTPRequest *)request;
- (void)serializePodsWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context;

@end

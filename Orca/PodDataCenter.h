//
//  PodDataCenter.h
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@class Pod;

@interface PodDataCenter : PSDataCenter {
}

+ (PodDataCenter *)defaultCenter;

/**
 Get pods from Server
 */
- (void)getPods;
- (void)getPodsFromFixtures;

/**
 Serialize pods from Server
 */
- (void)serializePodsWithRequest:(ASIHTTPRequest *)request;
- (void)serializePodsWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context;

/**
 Update Pod from compose
 */
- (void)updatePod:(Pod *)pod withUserInfo:(NSDictionary *)userInfo;

@end

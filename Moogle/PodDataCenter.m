//
//  PodDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PodDataCenter.h"

@implementation PodDataCenter

#pragma mark MoogleDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [self serializePodsWithDictionary:_response];
  [super dataCenterFinishedWithOperation:operation];
}

#pragma mark Serialize Response
- (void)serializePodsWithDictionary:(NSDictionary *)dictionary {
  // Core Data Serialize
}

@end

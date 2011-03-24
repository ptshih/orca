//
//  FeedDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedDataCenter.h"

@implementation FeedDataCenter

#pragma mark MoogleDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [self serializeFeedsWithDictionary:_response];
  [super dataCenterFinishedWithOperation:operation];
}

#pragma mark Serialize Response
- (void)serializeFeedsWithDictionary:(NSDictionary *)dictionary {
  // Core Data Serialize
}

@end

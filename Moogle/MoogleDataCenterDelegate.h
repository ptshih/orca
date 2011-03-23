/*
 *  MoogleDataCenterDelegate.h
 *  Moogle
 *
 *  Created by Peter Shih on 2/22/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

@class LINetworkOperation;

@protocol MoogleDataCenterDelegate <NSObject>

@optional
- (void)dataCenterDidFinish:(LINetworkOperation *)operation;
- (void)dataCenterDidFail:(LINetworkOperation *)operation;

@end

/*
 *  LINetworkOperationDelegate.h
 *  NetworkStack
 *
 *  Created by Peter Shih on 1/28/11.
 *  Copyright 2011 LinkedIn. All rights reserved.
 *
 */

@class LINetworkOperation;

@protocol LINetworkOperationDelegate <NSObject>

@optional
- (void)networkOperationDidStart:(LINetworkOperation *)operation;
- (void)networkOperationDidFinish:(LINetworkOperation *)operation;

- (void)networkOperationDidFail:(LINetworkOperation *)operation;
- (void)networkOperationDidCancel:(LINetworkOperation *)operation;
- (void)networkOperationDidTimeout:(LINetworkOperation *)operation;

- (void)networkOperation:(LINetworkOperation *)operation didReceiveResponseHeaders:(NSDictionary *)responseHeaders;

@end

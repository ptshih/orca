//
//  LINetworkQueue.h
//  NetworkStack
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LINetworkQueue : NSOperationQueue {
}

// Access shared instance
+ (LINetworkQueue *)sharedQueue;

// This will tell each LINetworkOperation to clear delegates and cancel operation
- (void)cancelAllOperations;

@end

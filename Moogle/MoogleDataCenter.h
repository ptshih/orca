//
//  MoogleDataCenter.h
//  Moogle
//
//  Created by Peter Shih on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MoogleObject.h"
#import "MoogleDataCenterDelegate.h"
#import "LINetworkOperation.h"
#import "LINetworkQueue.h"
#import "LICoreDataStack.h"
#import "JSON.h"

@interface MoogleDataCenter : MoogleObject <MoogleDataCenterDelegate> {
  id <MoogleDataCenterDelegate> _delegate;
  id _response;
  id _rawResponse;
  LINetworkOperation *_op;
}

@property (nonatomic, retain) id <MoogleDataCenterDelegate> delegate;
@property (nonatomic, retain) id response;
@property (nonatomic, retain) id rawResponse;
@property (nonatomic, retain) LINetworkOperation *op;

/**
 Send network operation to server (GET/POST)
 url - required defined in Constants.h
 method - optional (defaults to GET) defined in Constants.h (should be GET or POST)
 params - optional
 */
- (void)sendOperationWithURL:(NSURL *)url andMethod:(NSString *)method andParams:(NSDictionary *)params;

// Subclass should Implement AND call super's implementation
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation;
- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation;

@end

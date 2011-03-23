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
}

@property (nonatomic, retain) id <MoogleDataCenterDelegate> delegate;
@property (nonatomic, retain) id response;
@property (nonatomic, retain) id rawResponse;


// Subclass should Implement AND call super's implementation
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation;
- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation;

@end

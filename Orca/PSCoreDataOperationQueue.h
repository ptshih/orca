//
//  PSCoreDataOperationQueue.h
//  Orca
//
//  Created by Peter Shih on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSCoreDataOperationQueue : NSOperationQueue {
  
}

+ (PSCoreDataOperationQueue *)sharedQueue;

@end

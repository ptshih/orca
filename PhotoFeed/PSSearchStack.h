//
//  PSSearchStack.h
//  PhotoFeed
//
//  Created by Peter Shih on 6/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PSSearchStack : NSObject {
  NSOperationQueue *_searchQueue;
}

+ (PSSearchStack *)sharedSearch;
- (void)addOperation:(NSOperation *)op;
- (NSUInteger)opCount;

@end

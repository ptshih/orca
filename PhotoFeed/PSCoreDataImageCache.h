//
//  PSCoreDataImageCache.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LICoreDataStack.h"
#import "Constants.h"

@interface PSCoreDataImageCache : NSObject {
  NSMutableArray *_pendingRequests;
}

+ (PSCoreDataImageCache *)sharedCache;

- (void)cacheImageWithURLPath:(NSString *)URLPath forEntity:(id)entity;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error;

@end

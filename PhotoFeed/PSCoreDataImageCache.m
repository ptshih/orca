//
//  PSCoreDataImageCache.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCoreDataImageCache.h"
#import "ASIHTTPRequest.h"

static PSCoreDataImageCache *_sharedCache;

@implementation PSCoreDataImageCache

+ (PSCoreDataImageCache *)sharedCache {
  if (!_sharedCache) {
    _sharedCache = [[self alloc] init];
  }
  return _sharedCache;
}

- (id)init {
  self = [super init];
  if (self) {
    _pendingRequests = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)cacheImageWithURLPath:(NSString *)URLPath forEntity:(id)entity {
  // Fire the request
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:URLPath]];
  
  request.userInfo = [NSDictionary dictionaryWithObject:entity forKey:@"entity"];
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self requestFinished:request];
  }];
  
  // Request Failed Block
  [request setFailedBlock:^{
    NSError *error = [request error];
    [self requestFailed:request withError:error];
  }];
  
  // Start the Request
  [request startAsynchronous];
  
  [_pendingRequests addObject:request];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
  id entity = [request.userInfo objectForKey:@"entity"];
  if ([entity respondsToSelector:@selector(imageData)]) {
    [entity performSelector:@selector(setImageData:) withObject:[request responseData]];
    [LICoreDataStack saveSharedContextIfNeeded];
    [[NSNotificationCenter defaultCenter] postNotificationName:kImageCached object:nil userInfo:request.userInfo];
  }
  
  [_pendingRequests removeObject:request];
}

- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  [_pendingRequests removeObject:request];
}

@end

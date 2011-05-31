//
//  PSImageCache.h
//  PSNetworkStack
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 TODOs:
 - implement cachePolicy
 - implement disk storage
 - implement header caching
 
 - move to PSNetworkStack
 */

@interface PSImageCache : NSObject <NSCacheDelegate> {
}

+ (PSImageCache *)sharedCache;

// Image Cache
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath;
- (UIImage *)imageForURLPath:(NSString *)urlPath;
- (BOOL)hasImageForURLPath:(NSString *)urlPath;

// Helpers
+ (NSString *)applicationDocumentsDirectory;

@end

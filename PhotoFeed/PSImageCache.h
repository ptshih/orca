//
//  PSImageCache.h
//  PSNetworkStack
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PSImageCache : NSObject <NSCacheDelegate> {
  NSCache *_buffer;
  NSString *_cachePath;
  NSSearchPathDirectory _cacheDirectory;
}

@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, assign) NSSearchPathDirectory cacheDirectory;

+ (PSImageCache *)sharedCache;
- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory;

// Image Cache
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath;
- (UIImage *)imageForURLPath:(NSString *)urlPath;
- (BOOL)hasImageForURLPath:(NSString *)urlPath;

// Helpers
+ (NSString *)documentDirectory;
+ (NSString *)cachesDirectory;

@end

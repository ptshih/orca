//
//  PSImageCache.m
//  PSNetworkStack
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSImageCache.h"
#import "NSString+URLEncoding+PS.h"

static PSImageCache *_sharedCache;

static NSString *_cachePath = nil;

@implementation PSImageCache

+ (void)initialize {
  _cachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] copy];
  
  BOOL isDir = NO;
  NSError *error;
  if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath isDirectory:&isDir] && isDir == NO) {
    [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:NO attributes:nil error:&error];
  }
}

+ (PSImageCache *)sharedCache {
  if (!_sharedCache) {
    _sharedCache = [[self alloc] init];
  }
  return _sharedCache;
}

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

// Image Cache
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath {
  if (imageData) {
    [imageData writeToFile:[_cachePath stringByAppendingPathComponent:[urlPath encodedURLParameterString]] atomically:YES];
  }
}

- (UIImage *)imageForURLPath:(NSString *)urlPath {
  return [UIImage imageWithContentsOfFile:[_cachePath stringByAppendingPathComponent:[urlPath encodedURLParameterString]]];
}

- (BOOL)hasImageForURLPath:(NSString *)urlPath {
  static NSFileManager *fileManager = nil;
  if (!fileManager) {
    fileManager = [[NSFileManager alloc] init];
  }
  return [fileManager fileExistsAtPath:[_cachePath stringByAppendingPathComponent:[urlPath encodedURLString]]];
}

#pragma mark NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
  NSLog(@"NSCache evicting object: %@", obj);
}
   
#pragma mark Helpers
+ (NSString *)applicationDocumentsDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end

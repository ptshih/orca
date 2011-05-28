//
//  PSImageCache.m
//  PSNetworkStack
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSImageCache.h"

static PSImageCache *_sharedCache;

static NSString *_cachePath = nil;

@implementation PSImageCache

@synthesize imageCache = _imageCache;

+ (void)initialize {
  _cachePath = [[NSString stringWithFormat:@"%@/imageCache.plist", [[self class] applicationDocumentsDirectory]] retain];
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
    if (!_imageCache) {
      BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_cachePath];
      if (fileExists) {
        _imageCache = [[self readImageCacheFromDisk] retain];
      } else {
        _imageCache = [[NSMutableDictionary alloc] init];
      }
    }
  }
  return self;
}

// Image Cache
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath {
//  [self.imageCache setObject:imageData forKey:urlPath];
  UIImage *image = [UIImage imageWithData:imageData];
  if (image) {
    [self.imageCache setObject:[UIImage imageWithData:imageData] forKey:urlPath];
  }
//  [self flushImageCacheToDisk];
}

- (UIImage *)imageForURLPath:(NSString *)urlPath {
//  return [UIImage imageWithData:[self.imageCache objectForKey:urlPath]];
  return [self.imageCache objectForKey:urlPath];
}

- (BOOL)hasImageForURLPath:(NSString *)urlPath {
  return ([_imageCache objectForKey:urlPath] != nil);
}

- (NSMutableDictionary *)readImageCacheFromDisk {
  return [NSKeyedUnarchiver unarchiveObjectWithFile:_cachePath];
}

- (BOOL)flushImageCacheToDisk {
  return [NSKeyedArchiver archiveRootObject:_imageCache toFile:_cachePath];
}
   
#pragma mark Helpers
- (NSString *)encodedURLParameterString {
  NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                         (CFStringRef)self,
                                                                         NULL,
                                                                         CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                         kCFStringEncodingUTF8);
  
  return [result autorelease];
}

+ (NSString *)applicationDocumentsDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end

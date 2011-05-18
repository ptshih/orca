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

// Image Cache
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath {
  if (!_imageCache) {
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:_cachePath];
    if (fileExists) {
      _imageCache = [[self readImageCacheFromDisk] retain];
    } else {
      _imageCache = [[NSMutableDictionary alloc] init];
    }
  }
  
  [self.imageCache setObject:imageData forKey:urlPath];
}

- (UIImage *)imageForURLPath:(NSString *)urlPath {
  return [UIImage imageWithData:[self.imageCache objectForKey:urlPath]];
}

- (BOOL)hasImageForURLPath:(NSString *)urlPath {
  return ([_imageCache objectForKey:urlPath] != nil);
}

- (NSMutableDictionary *)readImageCacheFromDisk {
  // Read from file
  NSError *error = nil;
  NSData *imageCacheData = [NSData dataWithContentsOfFile:_cachePath];
  return [NSMutableDictionary dictionaryWithDictionary:[NSPropertyListSerialization propertyListWithData:imageCacheData options:0 format:NULL error:&error]];
}

- (BOOL)flushImageCacheToDisk {
  // Write to file
  NSError *error = nil;
  NSData *imageCacheData = [NSPropertyListSerialization dataWithPropertyList:_imageCache format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
  return [imageCacheData writeToFile:_cachePath atomically:YES];
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

#pragma mark Memory Management
+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (_sharedCache == nil) {
      _sharedCache = [super allocWithZone:zone];
      return _sharedCache;
    }
  }
  return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)retain {
  return self;
}

- (unsigned)retainCount {
  return UINT_MAX;
}

- (void)release {
  // do nothing
}

- (id)autorelease {
  return self;
}

@end

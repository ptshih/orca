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

@implementation PSImageCache

@synthesize cachePath = _cachePath;

+ (PSImageCache *)sharedCache {
  if (!_sharedCache) {
    _sharedCache = [[self alloc] init];
  }
  return _sharedCache;
}

- (id)init {
  self = [super init];
  if (self) {
    _buffer = [[NSCache alloc] init];
    [_buffer setName:@"PSImageCache"];
    [_buffer setDelegate:self];
    
    // Set to NSDocumentDirectory by default
    [self setupCachePathWithCacheDirectory:NSDocumentDirectory];
  }
  return self;
}

- (void)setupCachePathWithCacheDirectory:(NSSearchPathDirectory)cacheDirectory {
  self.cachePath = [[NSSearchPathForDirectoriesInDomains(cacheDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"psimagecache"];
  
  BOOL isDir = NO;
  NSError *error;
  if (![[NSFileManager defaultManager] fileExistsAtPath:_cachePath isDirectory:&isDir] && isDir == NO) {
    [[NSFileManager defaultManager] createDirectoryAtPath:_cachePath withIntermediateDirectories:NO attributes:nil error:&error];
  }
}

#pragma mark Setter/Getter for cacheDirectory
- (void)setCacheDirectory:(NSSearchPathDirectory)cacheDirectory {
  _cacheDirectory = cacheDirectory;
  
  // Change the cachePath to use the new directory
  [self setupCachePathWithCacheDirectory:cacheDirectory];
}

- (NSSearchPathDirectory)cacheDirectory {
  return _cacheDirectory;
}

- (void)dealloc {
  if (_buffer) [_buffer release], _buffer = nil;
  if (_cachePath) [_cachePath release], _cachePath = nil;
  [super dealloc];
}

// Cache Image Data
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath {
  if (imageData) {
    // First put it in the NSCache buffer
    [_buffer setObject:[UIImage imageWithData:imageData] forKey:[urlPath encodedURLParameterString]];
    
    // Also write it to file
    [imageData writeToFile:[_cachePath stringByAppendingPathComponent:[urlPath encodedURLParameterString]] atomically:YES];
    
    VLog(@"PSImageCache CACHE: %@", urlPath);
  }
}

// Read Cached Image
- (UIImage *)imageForURLPath:(NSString *)urlPath {
  // First check NSCache buffer
  //  NSData *imageData = [_buffer objectForKey:[urlPath encodedURLParameterString]];
  UIImage *image = [_buffer objectForKey:[urlPath encodedURLParameterString]];
  if (image) {
    // Image exists in buffer
    VLog(@"PSImageCache CACHE HIT: %@", urlPath);
    return image;
  } else {
    // Image not in buffer, read from disk instead
    VLog(@"PSImageCache CACHE MISS: %@", urlPath);
    image = [UIImage imageWithContentsOfFile:[_cachePath stringByAppendingPathComponent:[urlPath encodedURLParameterString]]];
    
    // If Image is in disk, read it
    if (image) {
      VLog(@"PSImageCache DISK HIT: %@", urlPath);
      // Put this image into the buffer also
      [_buffer setObject:image forKey:[urlPath encodedURLParameterString]];
      return image;
    } else {
      VLog(@"PSImageCache DISK MISS: %@", urlPath);
      return nil;
    }
  }
}

- (BOOL)hasImageForURLPath:(NSString *)urlPath {
  if ([_buffer objectForKey:[urlPath encodedURLParameterString]]) {
    // Image exists in memcache
    return YES;
  } else {
    // Check disk for image
    return [[NSFileManager defaultManager] fileExistsAtPath:[_cachePath stringByAppendingPathComponent:[urlPath encodedURLString]]];
  }
}

#pragma mark NSCacheDelegate
- (void)cache:(NSCache *)cache willEvictObject:(id)obj {
  VLog(@"NSCache evicting object");
}
   
#pragma mark Helpers
+ (NSString *)documentDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)cachesDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

@end

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
    _buffer = [[NSCache alloc] init];
    [_buffer setName:@"PSImageCache"];
    [_buffer setDelegate:self];
  }
  return self;
}

- (void)dealloc {
  if (_buffer) [_buffer release], _buffer = nil;
  [super dealloc];
}

// Cache Image Data
- (void)cacheImage:(NSData *)imageData forURLPath:(NSString *)urlPath {
  if (imageData) {
    // First put it in the NSCache buffer
    [_buffer setObject:[UIImage imageWithData:imageData] forKey:[urlPath encodedURLParameterString]];
    
    // Also write it to file
    [imageData writeToFile:[_cachePath stringByAppendingPathComponent:[urlPath encodedURLParameterString]] atomically:YES];
    
    NSLog(@"PSImageCache CACHE: %@", urlPath);
  }
}

// Read Cached Image
- (UIImage *)imageForURLPath:(NSString *)urlPath {
  // First check NSCache buffer
  //  NSData *imageData = [_buffer objectForKey:[urlPath encodedURLParameterString]];
  UIImage *image = [_buffer objectForKey:[urlPath encodedURLParameterString]];
  if (image) {
    // Image exists in buffer
    NSLog(@"PSImageCache CACHE HIT: %@", urlPath);
    return image;
  } else {
    // Image not in buffer, read from disk instead
    NSLog(@"PSImageCache CACHE MISS: %@", urlPath);
    image = [UIImage imageWithContentsOfFile:[_cachePath stringByAppendingPathComponent:[urlPath encodedURLParameterString]]];
    
    // If Image is in disk, read it
    if (image) {
      NSLog(@"PSImageCache DISK HIT: %@", urlPath);
      // Put this image into the buffer also
      [_buffer setObject:image forKey:[urlPath encodedURLParameterString]];
      return image;
    } else {
      NSLog(@"PSImageCache DISK MISS: %@", urlPath);
      return nil;
    }
  }
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
  NSLog(@"NSCache evicting object");
}
   
#pragma mark Helpers
+ (NSString *)applicationDocumentsDirectory {
  return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end

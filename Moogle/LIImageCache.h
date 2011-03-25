//
//  LIImageCache.h
//  InPad
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
 
 - move to NetworkStack
 */

@interface LIImageCache : NSObject {
  NSMutableDictionary *_imageCache;
}

@property (retain) NSMutableDictionary *imageCache;

+ (LIImageCache *)sharedCache;

// Image Cache
- (void)cacheImage:(UIImage *)image forURLPath:(NSString *)urlPath;
- (UIImage *)imageForURLPath:(NSString *)urlPath;
- (BOOL)hasImageForURLPath:(NSString *)urlPath;

@end

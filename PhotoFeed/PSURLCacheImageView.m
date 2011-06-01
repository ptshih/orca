//
//  PSURLCacheImageView.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSURLCacheImageView.h"
#import "PSImageCache.h"
#import "UIImage+ScalingAndCropping.h"
#import "NSString+URLEncoding+PS.h"

@implementation PSURLCacheImageView

@synthesize urlPath = _urlPath;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageCacheDidLoad:) name:kPSImageCacheDidCacheImage object:nil];
  }
  return self;
}

//- (void)setUrlPath:(NSString *)urlPath {
//  [_urlPath autorelease];
//  _urlPath = [[urlPath encodedURLString] copy];
//}

- (void)loadImage {
  if (_urlPath) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:_urlPath];
    if (image) {
      self.image = image;
    } else {
      self.image = _placeholderImage;
      [[PSImageCache sharedCache] loadImageForURLPath:_urlPath];
    }
  }
}

- (void)loadImageIfCached {
  if (_urlPath) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:_urlPath];
    if (image) {
      self.image = image;
    } else {
      self.image = _placeholderImage;
    }
  }
}

- (void)unloadImage {
  self.image = _placeholderImage;
  self.urlPath = nil;
}

- (void)imageCacheDidLoad:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  NSString *urlPath = [userInfo objectForKey:@"urlPath"];
  NSData *imageData = [userInfo objectForKey:@"imageData"];
  if ([urlPath isEqualToString:_urlPath]) {
    if (imageData) {
      UIImage *image = [UIImage imageWithData:imageData];
      if (image && ![image isEqual:self.image]) {
        self.image = image;
      }
    }
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSImageCacheDidCacheImage object:nil];
  RELEASE_SAFELY(_urlPath);
  [super dealloc];
}

@end
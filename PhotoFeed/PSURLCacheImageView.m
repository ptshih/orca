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

@implementation PSURLCacheImageView

@synthesize urlPath = _urlPath;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
  }
  return self;
}

- (void)loadImage {
  if (_urlPath) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:_urlPath];
    if (image) {
      self.image = image;
    } else {
      self.image = _placeholderImage;
      if (_request) {
        [_request clearDelegatesAndCancel];
        RELEASE_SAFELY(_request);
      }
      
      // Fire the request
      _request = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:_urlPath]] retain];
      
      // Request Completion Block
      [_request setCompletionBlock:^{
        [self requestFinished:_request];
      }];
      
      // Request Failed Block
      [_request setFailedBlock:^{
        NSError *error = [_request error];
        
        [self requestFailed:_request withError:error];
      }];
      
      // Start the Request
      [_request startAsynchronous];
    }
  }
}

- (void)loadImageIfCached {
  if (_urlPath) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:_urlPath];
    if (image) {
      self.image = image;
    }
  }
}

- (void)unloadImage {
  if (_request) [_request clearDelegatesAndCancel];
  RELEASE_SAFELY(_request);
  self.image = _placeholderImage;
  self.urlPath = nil;
}

#pragma mark Request Finished
- (void)requestFinished:(ASIHTTPRequest *)request {
  // URL
  NSURL *origURL = nil;
  origURL = [request originalURL];

  UIImage *image = [UIImage imageWithData:[request responseData]];
  UIImage *newImage = nil;
  if (image) {
    DLog(@"image size: %@, url: %@", NSStringFromCGSize([image size]), _urlPath);
    if (_shouldScale) {
      newImage = [image cropProportionalToSize:self.bounds.size];
    } else {
      newImage = image;
    }
    [[PSImageCache sharedCache] cacheImage:UIImageJPEGRepresentation(newImage, 1.0) forURLPath:[origURL absoluteString]];
  } else {
    DLog(@"image failed to load for url: %@", [origURL absoluteString]);
  }
  if (newImage) {
    if ([self.urlPath isEqualToString:[origURL absoluteString]]) {
      self.image = newImage;
    } else {
      DLog(@"urlpath: %@, origURL: %@ does NOT match", _urlPath, [origURL absoluteString]);
    }
  }
  
  //  NSLog(@"Image width: %f, height: %f", image.size.width, image.size.height);
}

#pragma mark Request Failed
- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  DLog(@"request: %@ failed with error: %@", request, error);
  self.image = _placeholderImage;
}

- (void)dealloc {
  if (_request) [_request clearDelegatesAndCancel];
  RELEASE_SAFELY(_request);
  RELEASE_SAFELY(_urlPath);
  
  [super dealloc];
}

@end
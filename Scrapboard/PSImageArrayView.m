//
//  PSImageArrayView.m
//  Scrapboard
//
//  Created by Peter Shih on 5/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSImageArrayView.h"
#import "PSImageCache.h"
#import "UIImage+ScalingAndCropping.h"
#import <QuartzCore/QuartzCore.h>

@implementation PSImageArrayView

@synthesize urlPathArray = _urlPathArray;
@synthesize shouldScale = _shouldScale;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _animateIndex = 0;
    _shouldScale = NO;
    _images = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)setImage:(UIImage *)image {
  [super setImage:[UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation]];
}

#pragma mark Array of Images
- (void)getImageRequestWithUrlPath:(NSString *)urlPath {
  // Fire the request
  ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlPath]];
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self requestFinished:request];
  }];
  
  // Request Failed Block
  [request setFailedBlock:^{
    NSError *error = [request error];
    
    [self requestFailed:request withError:error];
  }];
  
  // Start the Request
  [request startAsynchronous];
}

- (void)loadImageArray {
  [_images removeAllObjects];
  if (_urlPathArray) {
    for (NSString *urlPath in _urlPathArray) {
      UIImage *image = [[PSImageCache sharedCache] imageForURLPath:urlPath];
      if (image) {
        [_images setObject:image forKey:urlPath];
        [self checkImageArray];
      } else {
        [self getImageRequestWithUrlPath:urlPath];
      }
    }
  }
}

- (void)animateImages {
  NSArray *imageArray = [_images allValues];
  self.image = [imageArray objectAtIndex:_animateIndex];
  
  CABasicAnimation *crossFade = [CABasicAnimation animationWithKeyPath:@"contents"];
  crossFade.duration = 3.0;
  crossFade.fromValue = (id)[[imageArray objectAtIndex:_animateIndex] CGImage];
  
  _animateIndex++;
  if (_animateIndex == [_images count]) {
    _animateIndex = 0;
  }
  
  crossFade.toValue = (id)[[imageArray objectAtIndex:(_animateIndex)] CGImage];
  [self.layer addAnimation:crossFade forKey:@"animateContents"];
  
  self.image = [imageArray objectAtIndex:_animateIndex];
  
//  self.animationImages = _imageArray;
//	self.animationDuration = [_imageArray count] * 3.0;
//	[self startAnimating];
}
                             
- (void)requestFinished:(ASIHTTPRequest *)request {
  UIImage *image = [UIImage imageWithData:[request responseData]];
  UIImage *newImage = nil;
  if (image) {
    if (_shouldScale) {
      newImage = [image cropProportionalToSize:self.bounds.size];
    } else {
      newImage = image;
    }
    [[PSImageCache sharedCache] cacheImage:UIImageJPEGRepresentation(newImage, 1.0) forURLPath:[[request originalURL] absoluteString]];
  }
  if (newImage) {
    [_images setObject:newImage forKey:[[request originalURL] absoluteString]];
    [self checkImageArray];
  }
}

- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
}

- (void)checkImageArray {
  if ([_images count] == [_urlPathArray count] && !_animateTimer) {
//    [self animateImages];
    _animateTimer = [[NSTimer timerWithTimeInterval:6.0 target:self selector:@selector(animateImages) userInfo:nil repeats:YES] retain];
    [[NSRunLoop currentRunLoop] addTimer:_animateTimer forMode:NSDefaultRunLoopMode];
    [_animateTimer fire];
  }
}

- (void)dealloc {
  RELEASE_SAFELY(_urlPathArray);
  RELEASE_SAFELY(_images);
  INVALIDATE_TIMER(_animateTimer);
  
  [super dealloc];
}

@end

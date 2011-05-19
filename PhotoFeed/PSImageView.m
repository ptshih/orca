//
//  PSImageView.m
//  PSNetworkStack
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import "PSImageView.h"
#import "UIImage+ScalingAndCropping.h"

@implementation PSImageView

@synthesize placeholderImage = _placeholderImage;
@synthesize shouldScale = _shouldScale;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _shouldScale = NO;
    _placeholderImage = nil;
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _loadingIndicator.hidesWhenStopped = YES;
    _loadingIndicator.frame = self.bounds;
    _loadingIndicator.contentMode = UIViewContentModeCenter;
    [_loadingIndicator startAnimating];
    [self addSubview:_loadingIndicator];
    self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  _loadingIndicator.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
  // RETINA
  [super setImage:[UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation]];
  
  if (image != _placeholderImage) {
    [_loadingIndicator stopAnimating];
  } else {
    [_loadingIndicator startAnimating];
  }
}

- (void)dealloc {
  RELEASE_SAFELY(_loadingIndicator);
  RELEASE_SAFELY(_placeholderImage);
  
  [super dealloc];
}

@end

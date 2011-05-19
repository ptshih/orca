//
//  PSZoomView.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSZoomView.h"

#define CAPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]

@implementation PSZoomView

@synthesize zoomImageView = _zoomImageView;
@synthesize caption = _caption;
@synthesize oldImageFrame = _oldImageFrame;
@synthesize oldCaptionFrame = _oldCaptionFrame;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    
    _oldImageFrame = CGRectZero;
    _zoomImageView = [[PSImageView alloc] initWithFrame:frame];
    _zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
    _zoomImageView.userInteractionEnabled = YES;
    
    _shadeView = [[UIView alloc] initWithFrame:frame];
    _shadeView.backgroundColor = [UIColor blackColor];
    _shadeView.alpha = 0.0;
    
    _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 408, 320, 72)];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.font = CAPTION_FONT;
    _captionLabel.numberOfLines = 4;
    _captionLabel.textAlignment = UITextAlignmentCenter;
    _captionLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    _captionLabel.shadowColor = [UIColor blackColor];
    _captionLabel.shadowOffset = CGSizeMake(0, 1);
    _captionLabel.alpha = 0.0;
    
    [self addSubview:_shadeView];
    [self addSubview:_zoomImageView];
    [self addSubview:_captionLabel];
    
    UITapGestureRecognizer *removeTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissZoom)] autorelease];
    [self addGestureRecognizer:removeTap];
  }
  return self;
}

- (void)zoom {
  _captionLabel.text = _caption;
  _captionLabel.height = _oldCaptionFrame.size.height;
  _captionLabel.top = 480 - _captionLabel.height;
  
  [[[UIApplication sharedApplication] keyWindow] addSubview:self];
  
  [UIView beginAnimations:@"ZoomImage" context:nil];
  [UIView setAnimationDelegate:nil];
  //  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDuration:0.4]; // Fade out is configurable in seconds (FLOAT)
  _shadeView.alpha = 1.0;
  _captionLabel.alpha = 1.0;
  self.zoomImageView.center = [[[UIApplication sharedApplication] keyWindow] center];
  [UIView commitAnimations];
}

- (void)dismissZoom {
  [UIView beginAnimations:@"ZoomImage" context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(removeZoomView)];
  //  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDuration:0.4]; // Fade out is configurable in seconds (FLOAT)
  _shadeView.alpha = 0.0;
  _captionLabel.alpha = 0.0;
  self.zoomImageView.frame = _oldImageFrame;
  
  [UIView commitAnimations];
}
   
- (void)removeZoomView {
  [self removeFromSuperview];
}

- (void)dealloc {
  RELEASE_SAFELY(_zoomImageView);
  RELEASE_SAFELY(_shadeView);
  RELEASE_SAFELY(_caption);
  RELEASE_SAFELY(_captionLabel);
  [super dealloc];
}

@end

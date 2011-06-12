//
//  PSZoomView.m
//  Orca
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSZoomView.h"
#import "Photo.h"

#define CAPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]

@implementation PSZoomView

@synthesize zoomImageView = _zoomImageView;
@synthesize shadeView = _shadeView;
@synthesize captionLabel = _captionLabel;
@synthesize caption = _caption;
@synthesize oldImageFrame = _oldImageFrame;
@synthesize oldCaptionFrame = _oldCaptionFrame;
@synthesize photo = _photo;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _photo = nil;
    self.backgroundColor = [UIColor clearColor];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
//    self.autoresizesSubviews = YES;
    
    _oldImageFrame = CGRectZero;
    _zoomImageView = [[PSImageView alloc] initWithFrame:frame];
    _zoomImageView.contentMode = UIViewContentModeScaleAspectFit;
    _zoomImageView.userInteractionEnabled = YES;
//    _zoomImageView.alpha = 0.0;
    _zoomImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _shadeView = [[UIView alloc] initWithFrame:frame];
    _shadeView.backgroundColor = [UIColor blackColor];
    _shadeView.alpha = 0.0;
    _shadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 408, 320, 72)];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.font = CAPTION_FONT;
    _captionLabel.numberOfLines = 4;
    _captionLabel.textAlignment = UITextAlignmentCenter;
    _captionLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    _captionLabel.shadowColor = [UIColor blackColor];
    _captionLabel.shadowOffset = CGSizeMake(0, 1);
    _captionLabel.alpha = 0.0;
    _captionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    _containerView = [[UIView alloc] initWithFrame:self.bounds];
    _containerView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_shadeView];
    [self addSubview:_containerView];
    [_containerView addSubview:_zoomImageView];
    [_containerView addSubview:_captionLabel];

    
    // Gestures
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    pinchGesture.delegate = self;
    [_zoomImageView addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.maximumNumberOfTouches = 2;
    [_zoomImageView addGestureRecognizer:panGesture];
    [panGesture release];
    
    UITapGestureRecognizer *removeTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeZoom)] autorelease];
    [self addGestureRecognizer:removeTap];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChangedFromNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
  }
  return self;
}

#pragma mark -
#pragma mark Gestures
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
  
  if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
    // Reset the last scale, necessary if there are multiple objects with different scales
    _lastScale = [gestureRecognizer scale];
  }
  
  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
      [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
    
    CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
    
    // Constants to adjust the max/min values of zoom
    const CGFloat kMaxScale = 2.0;
    const CGFloat kMinScale = 1.0;
    
    CGFloat newScale = 1 -  (_lastScale - [gestureRecognizer scale]); // new scale is in the range (0-1)
    newScale = MIN(newScale, kMaxScale / currentScale);
    newScale = MAX(newScale, kMinScale / currentScale);
    CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
    [gestureRecognizer view].transform = transform;
    
    _lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
  }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
  UIView *piece = [gestureRecognizer view];
  
  if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
    CGPoint translation = [gestureRecognizer translationInView:[piece superview]];
    
    [piece setCenter:CGPointMake([piece center].x + translation.x, [piece center].y + translation.y)];
    [gestureRecognizer setTranslation:CGPointZero inView:[piece superview]];
  }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

- (void)showZoom {
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
//  _zoomImageView.alpha = 1.0;
  self.zoomImageView.center = [[[UIApplication sharedApplication] keyWindow] center];
  [UIView commitAnimations];
}

- (void)removeZoom {
  _containerView.transform = CGAffineTransformIdentity;
  _containerView.bounds = CGRectMake(0, 0, 320, 480);
  
  [UIView beginAnimations:@"ZoomImage" context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(removeZoomView)];
  //  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDuration:0.4]; // Fade out is configurable in seconds (FLOAT)
  _shadeView.alpha = 0.0;
  _captionLabel.alpha = 0.0;
//  _zoomImageView.alpha = 0.0;
  _zoomImageView.frame = _oldImageFrame;
  
  [UIView commitAnimations];
}

- (void)removeZoomView {
  [self removeFromSuperview];
  _zoomImageView.transform = CGAffineTransformIdentity;
}

- (void)orientationChangedFromNotification:(NSNotification *)notification {
  UIDevice *device = [notification object];
  UIDeviceOrientation orientation = [device orientation];

  [UIView beginAnimations:@"ViewOrientationChange" context:nil];
  [UIView setAnimationDuration:0.4];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
  
  switch (orientation) {
    case UIDeviceOrientationPortrait:
      _containerView.transform = CGAffineTransformIdentity;
      _containerView.bounds = CGRectMake(0, 0, 320, 480);
      break;
    case UIDeviceOrientationPortraitUpsideDown:
      _containerView.transform = CGAffineTransformIdentity;
      _containerView.transform = CGAffineTransformMakeRotation(RADIANS(180));
      _containerView.bounds = CGRectMake(0, 0, 320, 480);
      break;
    case UIDeviceOrientationLandscapeLeft:
      _containerView.transform = CGAffineTransformIdentity;
      _containerView.transform = CGAffineTransformMakeRotation(RADIANS(90));
      _containerView.bounds = CGRectMake(0, 0, 480, 320);
      break;
    case UIDeviceOrientationLandscapeRight:
      _containerView.transform = CGAffineTransformIdentity;
      _containerView.transform = CGAffineTransformMakeRotation(RADIANS(270));
      _containerView.bounds = CGRectMake(0, 0, 480, 320);
      break;
    default:
      // face up or face down, no-op
      break;
  }
  
  [UIView commitAnimations];
}

- (void)dealloc {
  [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
  RELEASE_SAFELY(_zoomImageView);
  RELEASE_SAFELY(_shadeView);
  RELEASE_SAFELY(_caption);
  RELEASE_SAFELY(_captionLabel);
  RELEASE_SAFELY(_containerView);
  [super dealloc];
}

@end

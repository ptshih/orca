//
//  ZoomViewController.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ZoomViewController.h"
#import "PSZoomView.h"

@implementation ZoomViewController

@synthesize zoomView = _zoomView;

- (id)init {
  self = [super init];
  if (self) {
    self.wantsFullScreenLayout = YES;
    self.view = [[[PSZoomView alloc] initWithFrame:[[APP_DELEGATE.launcherViewController view  ] bounds]] autorelease];
    _zoomView = (PSZoomView *)self.view;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    UITapGestureRecognizer *removeTap = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissZoom)] autorelease];
    [_zoomView addGestureRecognizer:removeTap];
  }
  return self;
}

- (void)loadView {
  [super loadView];
}

- (void)dismissZoom {
  [self performSelector:@selector(removeZoomView) withObject:nil afterDelay:0.1];
  [UIView beginAnimations:@"ZoomImage" context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(removeZoomView)];
  //  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [UIView setAnimationDuration:0.4]; // Fade out is configurable in seconds (FLOAT)
  _zoomView.shadeView.alpha = 0.0;
  _zoomView.captionLabel.alpha = 0.0;
  _zoomView.zoomImageView.frame = _zoomView.oldImageFrame;
  
  [UIView commitAnimations];
}

- (void)removeZoomView {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)zoom {
  [APP_DELEGATE.launcherViewController presentModalViewController:self animated:YES];
  
//  [[APP_DELEGATE.launcherViewController view] addSubview:self.view];
//  [[[UIApplication sharedApplication] keyWindow] addSubview:self.view];
  [_zoomView performSelector:@selector(zoom) withObject:nil afterDelay:0.1];
//  [_zoomView zoom];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

@end

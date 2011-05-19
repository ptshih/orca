//
//  PSZoomView.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSView.h"
#import "PSImageView.h"

@interface PSZoomView : PSView {
  PSImageView *_zoomImageView;
  UIView *_shadeView;
  NSString *_caption;
  UILabel *_captionLabel;
  CGRect _oldImageFrame;
  CGRect _oldCaptionFrame;
}

@property (nonatomic, retain) PSImageView *zoomImageView;
@property (nonatomic, retain) NSString *caption;
@property (nonatomic, assign) CGRect oldImageFrame;
@property (nonatomic, assign) CGRect oldCaptionFrame;

- (void)zoom;
- (void)dismissZoom;
- (void)removeZoomView;

@end

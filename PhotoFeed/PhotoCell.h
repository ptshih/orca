//
//  PhotoCell.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCell.h"
#import "Photo.h"
#import "PhotoCellDelegate.h"

@interface PhotoCell : PSCell {
  PSImageView *_photoView; // optional
  UIView *_captionView;
  UILabel *_captionLabel;
  UIButton *_commentView;
  UILabel *_commentLabel;
  
  CGFloat _photoWidth;
  CGFloat _photoHeight;
  
  Photo *_photo;
  id <PhotoCellDelegate> _delegate;
}

@property (nonatomic, assign) PSImageView *photoView;
@property (nonatomic, assign) UILabel *captionLabel;
@property (nonatomic, assign) id <PhotoCellDelegate> delegate;

- (void)pinchZoom:(UIPinchGestureRecognizer *)gesture;
- (void)triggerPinch;
- (void)commentsSelected;
- (void)loadPhoto:(NSNotification *)notification;

@end

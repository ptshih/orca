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

@interface PhotoCell : PSCell {
  PSImageView *_photoView; // optional
  UIView *_captionView;
  UILabel *_captionLabel;
  
  CGFloat _photoWidth;
  CGFloat _photoHeight;
  
  Photo *_photo;
}

@property (nonatomic, assign) PSImageView *photoView;
@property (nonatomic, assign) UILabel *captionLabel;

- (void)loadPhoto:(NSNotification *)notification;

@end

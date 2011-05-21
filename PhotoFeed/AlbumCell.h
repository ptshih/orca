//
//  AlbumCell.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCell.h"
#import "Album.h"

@interface AlbumCell : PSCell {
  PSImageView *_photoView;
  UIView *_captionView;
  UIView *_ribbonView;
  
  UILabel *_nameLabel;
  UILabel *_captionLabel;
  UILabel *_fromLabel;
  UILabel *_locationLabel;
  UILabel *_countLabel;
  
  CGFloat _photoWidth;
  CGFloat _photoHeight;
  
  Album *_album;
  BOOL _isAnimating;
}

- (void)setPhotoViewWithImage:(UIImage *)newImage;
- (void)loadPhoto:(NSNotification *)notification;
- (void)animateImage;

@end

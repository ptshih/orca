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
}

- (void)loadPhoto;
- (void)loadPhotoIfCached;

@end

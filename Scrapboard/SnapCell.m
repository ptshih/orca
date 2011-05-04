//
//  SnapCell.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SnapCell.h"

#define PHOTO_SIZE 100.0
#define PHOTO_SPACING 10.0

@implementation SnapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _photoImageView = [[PSImageView alloc] initWithFrame:CGRectMake(0, 0, PHOTO_SIZE, PHOTO_SIZE)];
    
    [self.contentView addSubview:_photoImageView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = self.contentView.width - MARGIN_X * 2;
  
  // Optional Photo Thumbnail
//  if (_snap.photoFileName) {
//    [self.contentView addSubview:_photoFrameView];
//    _photoFrameView.left = left - 5;
//    _photoFrameView.top = top;
//    _photoFrameView.width = PHOTO_SIZE + PHOTO_SPACING * 2;
//    _photoFrameView.height = PHOTO_SIZE + PHOTO_SPACING * 2;
//    [self.contentView addSubview:_photoImageView];
//    _photoImageView.left = left + PHOTO_SPACING - 5;
//    _photoImageView.top = top + PHOTO_SPACING;
//    _photoImageView.width = PHOTO_SIZE;
//    _photoImageView.height = PHOTO_SIZE;
//    //    _photoImageView.layer.masksToBounds = YES;
//    //    _photoImageView.layer.cornerRadius = 10.0;
//  } else {
//    [_photoFrameView removeFromSuperview];
//    [_photoImageView removeFromSuperview];
//  }
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return 120;
}

- (void)fillCellWithObject:(id)object {
  
}

- (void)dealloc {
  [super dealloc];
}

@end

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

#define CAPTION_HEIGHT 40.0

@implementation SnapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    CGFloat cellWidth = self.contentView.width - MARGIN_X * 2;
    
    _photoView = [[PSImageView alloc] initWithFrame:CGRectMake(MARGIN_X, MARGIN_Y, cellWidth, cellWidth)];
    _photoView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _photoView.layer.borderWidth = 1.0;
    
    _captionView = [[UIView alloc] initWithFrame:CGRectMake(0, _photoView.height - CAPTION_HEIGHT , _photoView.width, CAPTION_HEIGHT)];
    _captionView.backgroundColor = [UIColor darkGrayColor];
    _captionView.layer.opacity = 0.9;
    
    [_photoView addSubview:_captionView];
    
    [self.contentView addSubview:_photoView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
//  CGFloat top = MARGIN_Y;
//  CGFloat left = MARGIN_X;
//  CGFloat textWidth = self.contentView.width - MARGIN_X * 2;
//  
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  CGFloat cellWidth = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation];
  CGFloat desiredHeight = 0;
  
  // Top Margin
  desiredHeight += MARGIN_Y;
  
  // Photo
  desiredHeight += cellWidth - MARGIN_X * 2;
  
  // Bottom Margin
  desiredHeight += MARGIN_Y;
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Snap *snap = (Snap *)object;
  
  // Photo
  _photoView.urlPath = snap.photoUrl;
}

- (void)loadPhoto {
  [_photoView loadImage];
}

- (void)dealloc {
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_captionView);
  [super dealloc];
}

@end

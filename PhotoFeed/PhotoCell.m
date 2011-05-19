//
//  PhotoCell.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoCell.h"

#define CAPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]

@implementation PhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _captionLabel = [[UILabel alloc] init];
    
    // Background Color
    _captionLabel.backgroundColor = [UIColor clearColor];
    
    // Font
    _captionLabel.font = CAPTION_FONT;
    
    // Text Color
    _captionLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    
    // Line Break Mode
    _captionLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    // Number of Lines
    _captionLabel.numberOfLines = 2;
    
    // Shadows
    _captionLabel.shadowColor = [UIColor blackColor];
    _captionLabel.shadowOffset = CGSizeMake(0, 1);
    
    // Caption
    _captionView = [[UIView alloc] init];
    _captionView.backgroundColor = [UIColor blackColor];
    _captionView.layer.opacity = 0.667;
    
    // Photo
    _photoView = [[PSImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    _photoView.shouldScale = YES;
    //    _photoView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    //    _photoView.layer.borderWidth = 1.0;
    
    // Add to contentView
    [self.contentView addSubview:_photoView];
    [self.contentView addSubview:_captionView];
    
    // Add labels
    [self.contentView addSubview:_captionLabel];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _captionLabel.text = nil;
  [_photoView unloadImage];
}

- (void)layoutSubviews {
  [super layoutSubviews];

  CGFloat top = _photoView.bottom;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = self.contentView.width - MARGIN_X * 2;
  CGSize desiredSize = CGSizeZero;
  
  // Caption Label
  if ([_captionLabel.text length] > 0) {    
    // Caption
    desiredSize = [UILabel sizeForText:_captionLabel.text width:textWidth font:_captionLabel.font numberOfLines:2 lineBreakMode:_captionLabel.lineBreakMode];
    _captionLabel.top = top + MARGIN_Y;
    _captionLabel.left = left;
    _captionLabel.width = desiredSize.width;
    _captionLabel.height = desiredSize.height;

    // Caption View
    _captionView.top = top;
    _captionView.left = 0;
    _captionView.height = _captionLabel.height + MARGIN_Y * 2;
    _captionView.width = self.contentView.width;
    
    // Move Captions up
    _captionView.top -= _captionView.height;
    _captionLabel.top -= _captionView.height;
  }
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//  Photo *photo = (Photo *)object;
  
  CGFloat cellWidth = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation];
  CGFloat desiredHeight = 0;
  
  // Photo
  desiredHeight += cellWidth;

  // Caption
//  if ([photo.name length] > 0) {
//    desiredHeight += [UILabel sizeForText:photo.name width:(cellWidth - MARGIN_X * 2) font:CAPTION_FONT numberOfLines:2 lineBreakMode:UILineBreakModeWordWrap].height;
//    desiredHeight += MARGIN_Y * 2;
//  }
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Photo *photo = (Photo *)object;
  
  // Photo
  _photoView.urlPath = photo.source;
  
  // Caption
  _captionLabel.text = photo.name;
  
  [self loadPhotoIfCached];
}

- (void)loadPhoto {
//  DLog(@"loadPhoto %@ for %@", [_photoView urlPath], _test);
  [_photoView loadImage];
}

- (void)loadPhotoIfCached {
  [_photoView loadImageIfCached];
}

- (void)dealloc {
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_captionView);
  
  RELEASE_SAFELY(_captionLabel);
  [super dealloc];
}

@end

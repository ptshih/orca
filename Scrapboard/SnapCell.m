//
//  SnapCell.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SnapCell.h"

#define CAPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]

#define PHOTO_SIZE 100.0
#define PHOTO_SPACING 10.0

#define CAPTION_HEIGHT 40.0

@implementation SnapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    CGFloat cellWidth = self.contentView.width - MARGIN_X * 2;
    
    // Photo
    _photoView = [[PSImageView alloc] initWithFrame:CGRectMake(MARGIN_X, MARGIN_Y, cellWidth, cellWidth)];
    _photoView.shouldScale = YES;
    _photoView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    _photoView.layer.borderWidth = 1.0;
    
    // Caption
    _captionView = [[UIView alloc] initWithFrame:CGRectMake(0, _photoView.height - CAPTION_HEIGHT , _photoView.width, CAPTION_HEIGHT)];
    _captionView.backgroundColor = [UIColor blackColor];
    _captionView.layer.opacity = 0.8;
    
    // Caption Label
    CGRect cf = CGRectMake(MARGIN_X, 0, _captionView.width - MARGIN_X * 2, _captionView.height);
    _captionLabel = [[UILabel alloc] initWithFrame:cf];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.textColor = [UIColor whiteColor];
    _captionLabel.numberOfLines = 2;
    _captionLabel.font = CAPTION_FONT;
    
    [_captionView addSubview:_captionLabel];
    
    [_photoView addSubview:_captionView];
    
    // Ribbon
    _ribbonView = [[UIView alloc] init];
    [_photoView addSubview:_ribbonView];
    
    [self.contentView addSubview:_photoView];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _ribbonView.hidden = YES;
  
  _captionLabel.text = nil;
  
  [_photoView unloadImage];
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
  
  _test = snap.id;
  
  // Photo
  _photoView.urlPath = snap.photoUrl;
  
  // Caption
  _captionLabel.text = snap.caption;
  
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
  RELEASE_SAFELY(_ribbonView);
  
  RELEASE_SAFELY(_captionLabel);
  [super dealloc];
}

@end

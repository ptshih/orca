//
//  FeedCell.m
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 13.0
#define TIMESTAMP_FONT_SIZE 12.0
#define PHOTO_SIZE 100.0
#define PHOTO_SPACING 5.0

@implementation FeedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _nameLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    _statusLabel = [[UILabel alloc] init];
    _commentLabel = [[UILabel alloc] init];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _commentLabel.backgroundColor = [UIColor clearColor];
    
    _nameLabel.font = [UIFont boldSystemFontOfSize:NAME_FONT_SIZE];
    _timestampLabel.font = [UIFont systemFontOfSize:TIMESTAMP_FONT_SIZE];
    _statusLabel.font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
    _commentLabel.font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
    
    _timestampLabel.textColor = GRAY_COLOR;
    
    _nameLabel.textAlignment = UITextAlignmentLeft;
    _timestampLabel.textAlignment = UITextAlignmentRight;
    _statusLabel.textAlignment = UITextAlignmentLeft;
    _commentLabel.textAlignment = UITextAlignmentLeft;
    
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _statusLabel.lineBreakMode = UILineBreakModeWordWrap;
    _commentLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    _nameLabel.numberOfLines = 1;
    _timestampLabel.numberOfLines = 1;
    _statusLabel.numberOfLines = 4;
    _commentLabel.numberOfLines = 8;
    
    _photoImageView = [[MoogleImageView alloc] init];
    [self.contentView addSubview:_photoImageView];
    
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_timestampLabel];
    [self.contentView addSubview:_statusLabel];
    [self.contentView addSubview:_commentLabel];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = IMAGE_WIDTH_PLAIN + SPACING_X * 2; // spacers: left of img, right of img
  CGFloat textWidth = self.contentView.width - left;
  CGSize textSize = CGSizeZero;
  CGSize labelSize = CGSizeZero;
  
  // Row 1
  
  // Timestamp Label
  textSize = CGSizeMake(textWidth, INT_MAX);
  labelSize = [_timestampLabel.text sizeWithFont:_timestampLabel.font constrainedToSize:textSize lineBreakMode:_timestampLabel.lineBreakMode];
  _timestampLabel.width = labelSize.width;
  _timestampLabel.height = labelSize.height;
  _timestampLabel.left = self.contentView.width - _timestampLabel.width - SPACING_X;
  _timestampLabel.top = top;
  
  // Name Label
  textSize = CGSizeMake(textWidth - _timestampLabel.width - SPACING_X, INT_MAX);
  labelSize = [_nameLabel.text sizeWithFont:_nameLabel.font constrainedToSize:textSize lineBreakMode:_nameLabel.lineBreakMode];
  _nameLabel.width = labelSize.width;
  _nameLabel.height = labelSize.height;
  _nameLabel.left = left;
  _nameLabel.top = top;
  
  // Row 2
  top = _nameLabel.bottom;
  
  // Status Label
  textSize = CGSizeMake(textWidth, INT_MAX);
  labelSize = [_statusLabel.text sizeWithFont:_statusLabel.font constrainedToSize:textSize lineBreakMode:_statusLabel.lineBreakMode];
  _statusLabel.width = labelSize.width;
  _statusLabel.height = labelSize.height;
  _statusLabel.left = left;
  _statusLabel.top = top;
  
  // Row 3
  top = _statusLabel.bottom;
  
  // Activity Label
  textSize = CGSizeMake(textWidth, INT_MAX);
  labelSize = [_commentLabel.text sizeWithFont:_commentLabel.font constrainedToSize:textSize lineBreakMode:_commentLabel.lineBreakMode];
  _commentLabel.width = labelSize.width;
  _commentLabel.height = labelSize.height;
  _commentLabel.left = left;
  _commentLabel.top = top;
  
  // Row 4
  top = _commentLabel.bottom;
  
  // Photo Image View
  _photoImageView.left = left;
  _photoImageView.top = top + PHOTO_SPACING;
  _photoImageView.width = PHOTO_SIZE;
  _photoImageView.height = PHOTO_SIZE;
  _photoImageView.layer.masksToBounds = YES;
  _photoImageView.layer.cornerRadius = 4.0;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _timestampLabel.text = nil;
  _statusLabel.text = nil;
  _commentLabel.text = nil;
}

- (void)fillCellWithFeed:(Feed *)feed {
  _nameLabel.text = feed.authorName;
  _timestampLabel.text = [feed.timestamp humanIntervalSinceNow];
  _statusLabel.text = [NSString stringWithFormat:@"Checked in here."];
  _commentLabel.text = feed.comment;
  
  _moogleImageView.urlPath = feed.authorPictureUrl;
  [_moogleImageView loadImage];
  
  _photoImageView.urlPath = feed.photoUrl;
  [_photoImageView loadImage];
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

// This is a class method because it is called before the cell has finished its layout
+ (CGFloat)variableRowHeightWithFeed:(Feed *)feed {
  CGFloat calculatedHeight = MARGIN_Y; // Top Spacer
  CGFloat left = IMAGE_WIDTH_PLAIN + SPACING_X * 2; // spacers: left of img, right of img
  CGFloat textWidth = [[self class] rowWidth] - left;
  CGSize textSize = CGSizeMake(textWidth, INT_MAX); // Variable height
  CGSize labelSize = CGSizeZero;
  UIFont *font = nil;
  
  // Name (Row 1)
  font = [UIFont boldSystemFontOfSize:NAME_FONT_SIZE];
  labelSize = [feed.authorName sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeTailTruncation];
  calculatedHeight += labelSize.height;
  
  // Status
  font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
  NSString *statusString = [NSString stringWithFormat:@"Checked in here."];
  labelSize = [statusString sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
  calculatedHeight += labelSize.height;
  
  // Comment
  font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
  labelSize = [feed.comment sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
  calculatedHeight += labelSize.height;
  
  // Photo
  calculatedHeight += PHOTO_SIZE + PHOTO_SPACING;
  
  // Bottom Spacer
  calculatedHeight += MARGIN_Y; // This is spacing*2 because its for top AND bottom
  
  // If height is less than image, adjust
  if (calculatedHeight < IMAGE_HEIGHT_PLAIN + (SPACING_Y * 2)) {
    calculatedHeight = IMAGE_HEIGHT_PLAIN + (SPACING_Y * 2);
  }
  
  return calculatedHeight;
}

- (void)dealloc {
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_statusLabel);
  RELEASE_SAFELY(_commentLabel);
  RELEASE_SAFELY(_photoImageView);
  [super dealloc];
}

@end
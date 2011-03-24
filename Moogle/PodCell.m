//
//  PodCell.m
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PodCell.h"

#define NAME_FONT_SIZE 13.0
#define CELL_FONT_SIZE 13.0
#define TIMESTAMP_FONT_SIZE 12.0

@implementation PodCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _nameLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    _summaryLabel = [[UILabel alloc] init];
    _activityLabel = [[UILabel alloc] init];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    _summaryLabel.backgroundColor = [UIColor clearColor];
    _activityLabel.backgroundColor = [UIColor clearColor];
    
    _nameLabel.font = [UIFont boldSystemFontOfSize:NAME_FONT_SIZE];
    _timestampLabel.font = [UIFont systemFontOfSize:TIMESTAMP_FONT_SIZE];
    _summaryLabel.font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
    _activityLabel.font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
    
    _timestampLabel.textColor = GRAY_COLOR;

    _nameLabel.textAlignment = UITextAlignmentLeft;
    _timestampLabel.textAlignment = UITextAlignmentRight;
    _summaryLabel.textAlignment = UITextAlignmentLeft;
    _activityLabel.textAlignment = UITextAlignmentLeft;
    
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
    _activityLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    _nameLabel.numberOfLines = 1;
    _timestampLabel.numberOfLines = 1;
    _summaryLabel.numberOfLines = 4;
    _activityLabel.numberOfLines = 1;
    
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_timestampLabel];
    [self.contentView addSubview:_summaryLabel];
    [self.contentView addSubview:_activityLabel];
  }
  return self;
}
    
- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = SPACING_Y;
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
  
  // Summary Label
  textSize = CGSizeMake(textWidth, INT_MAX);
  labelSize = [_summaryLabel.text sizeWithFont:_summaryLabel.font constrainedToSize:textSize lineBreakMode:_summaryLabel.lineBreakMode];
  _summaryLabel.width = labelSize.width;
  _summaryLabel.height = labelSize.height;
  _summaryLabel.left = left;
  _summaryLabel.top = top;
  
  // Row 3
  top = _summaryLabel.bottom;
  
  // Activity Label
  textSize = CGSizeMake(textWidth, INT_MAX);
  labelSize = [_activityLabel.text sizeWithFont:_activityLabel.font constrainedToSize:textSize lineBreakMode:_activityLabel.lineBreakMode];
  _activityLabel.width = labelSize.width;
  _activityLabel.height = labelSize.height;
  _activityLabel.left = left;
  _activityLabel.top = top;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _timestampLabel.text = nil;
  _summaryLabel.text = nil;
  _activityLabel.text = nil;
}

- (void)fillCellWithPod:(Pod *)pod {
  _nameLabel.text = pod.name;
  _timestampLabel.text = [pod.timestamp humanIntervalSinceNow];
  _summaryLabel.text = pod.summary;
  _activityLabel.text = [NSString stringWithFormat:@"%@ check-ins, %@ comments", pod.checkinCount, pod.commentCount];
  
  _moogleImageView.urlPath = pod.pictureUrl;
  [_moogleImageView loadImage];
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

// This is a class method because it is called before the cell has finished its layout
+ (CGFloat)variableRowHeightWithPod:(Pod *)pod {
  CGFloat calculatedHeight = SPACING_Y; // Top Spacer
  CGFloat left = IMAGE_WIDTH_PLAIN + SPACING_X * 2; // spacers: left of img, right of img
  CGFloat textWidth = [[self class] rowWidth] - left;
  CGSize textSize = CGSizeMake(textWidth, INT_MAX); // Variable height
  CGSize labelSize = CGSizeZero;
  UIFont *font = nil;
  
  // Name
  font = [UIFont boldSystemFontOfSize:NAME_FONT_SIZE];
  labelSize = [pod.name sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeTailTruncation];
  calculatedHeight += 15;
  
  // Summary
  font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
  labelSize = [pod.summary sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
  calculatedHeight += labelSize.height;
  
  // Activity
  font = [UIFont systemFontOfSize:CELL_FONT_SIZE];
  labelSize = [[NSString stringWithFormat:@"%@ check-ins, %@ comments", pod.checkinCount, pod.commentCount] sizeWithFont:font constrainedToSize:textSize lineBreakMode:UILineBreakModeTailTruncation];
  calculatedHeight += labelSize.height;
    
  // Bottom Spacer
  calculatedHeight += SPACING_Y; // This is spacing*2 because its for top AND bottom
  
  // If height is less than image, adjust
  if (calculatedHeight < IMAGE_HEIGHT_PLAIN + (SPACING_Y * 2)) {
    calculatedHeight = IMAGE_HEIGHT_PLAIN + (SPACING_Y * 2);
  }
  
  return calculatedHeight;
}

- (void)dealloc {
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_summaryLabel);
  RELEASE_SAFELY(_activityLabel);
  [super dealloc];
}

@end

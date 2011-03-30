//
//  PodCell.m
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PodCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 13.0
#define TIMESTAMP_FONT_SIZE 12.0
#define UNREAD_WIDTH 13.0

static UIImage *_unreadImage = nil;

@implementation PodCell

+ (void)initialize {
  _unreadImage = [[UIImage imageNamed:@"unread.png"] retain];
}

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
    
    _nameLabel.lineBreakMode = UILineBreakModeWordWrap;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
    _activityLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    _nameLabel.numberOfLines = 2;
    _timestampLabel.numberOfLines = 1;
    _summaryLabel.numberOfLines = 8;
    _activityLabel.numberOfLines = 1;
    
    _unreadImageView = [[UIImageView alloc] initWithImage:_unreadImage];
    
    [self.contentView addSubview:_unreadImageView];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_timestampLabel];
    [self.contentView addSubview:_summaryLabel];
    [self.contentView addSubview:_activityLabel];
  }
  return self;
}
    
- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = 0.0;

  // Unread Indicator
  _unreadImageView.left = left;
  _unreadImageView.top = floor(self.height / 2 - _unreadImageView.height / 2);
  
  _photoFrameView.left += _unreadImageView.right;
  _moogleImageView.left = _photoFrameView.left + SPACING_X;
  _imageLoadingIndicator.left += _unreadImageView.right;
  
  left = _photoFrameView.right;
  
  // Row 1
  
  // Timestamp Label
  textWidth = self.contentView.width - left - SPACING_X;
  [_timestampLabel sizeToFitFixedWidth:textWidth];
  _timestampLabel.left = self.contentView.width - _timestampLabel.width - SPACING_X;
  _timestampLabel.top = top + 1;
  
  // Name Label
  textWidth = self.contentView.width - left - _timestampLabel.width - SPACING_X * 2;
  [_nameLabel sizeToFitFixedWidth:textWidth];
  _nameLabel.left = left;
  _nameLabel.top = top;

  // Row 2
  top = _nameLabel.bottom;
  
  // Summary Label
  textWidth = self.contentView.width - left - SPACING_X;
  [_summaryLabel sizeToFitFixedWidth:textWidth];
  _summaryLabel.left = left;
  _summaryLabel.top = top;
  
  // Row 3
  top = _summaryLabel.bottom;
  
  // Activity Label
  textWidth = self.contentView.width - left - SPACING_X;
  [_activityLabel sizeToFitFixedWidth:textWidth];
  _activityLabel.left = left;
  _activityLabel.top = top;
  
  // Set desired height
  _desiredHeight = _activityLabel.bottom + MARGIN_Y;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _timestampLabel.text = nil;
  _summaryLabel.text = nil;
  _activityLabel.text = nil;
  _unreadImageView.hidden = NO;
}

- (void)fillCellWithObject:(id)object {
  Pod *pod = (Pod *)object;
  _nameLabel.text = pod.name;
  _timestampLabel.text = [pod.timestamp humanIntervalSinceNow];
  _summaryLabel.text = pod.summary;
  _activityLabel.text = [NSString stringWithFormat:@"%@ check-ins, %@ comments", pod.checkinCount, pod.commentCount];
  
  _moogleImageView.urlPath = pod.pictureUrl;
  [_moogleImageView loadImage];
  
  if ([pod.isRead boolValue]) {
    _unreadImageView.hidden = YES;
  } else {
    _unreadImageView.hidden = NO;
  }
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

- (void)dealloc {
  RELEASE_SAFELY(_unreadImageView);
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_summaryLabel);
  RELEASE_SAFELY(_activityLabel);
  [super dealloc];
}

@end

//
//  PlaceCell.m
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 12.0
#define TIMESTAMP_FONT_SIZE 12.0
#define ADDRESS_FONT_SIZE 12.0
#define UNREAD_WIDTH 13.0

static UIImage *_unreadImage = nil;

@implementation PlaceCell

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
    _lastActivityLabel = [[UILabel alloc] init];
    _addressLabel = [[UILabel alloc] init];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    _summaryLabel.backgroundColor = [UIColor clearColor];
    _activityLabel.backgroundColor = [UIColor clearColor];
    _lastActivityLabel.backgroundColor = [UIColor clearColor];
    _addressLabel.backgroundColor = [UIColor clearColor];
    
    _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE];
    _timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE];
    _summaryLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE];
    _activityLabel.font = [UIFont fontWithName:@"Futura-Medium" size:CELL_FONT_SIZE];
    _lastActivityLabel.font = [UIFont fontWithName:@"Futura-Medium" size:CELL_FONT_SIZE];
    _addressLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:ADDRESS_FONT_SIZE];
    
    
    _timestampLabel.textColor = GRAY_COLOR;

    _nameLabel.textAlignment = UITextAlignmentLeft;
    _timestampLabel.textAlignment = UITextAlignmentRight;
    _summaryLabel.textAlignment = UITextAlignmentLeft;
    _activityLabel.textAlignment = UITextAlignmentLeft;
    _lastActivityLabel.textAlignment = UITextAlignmentLeft;
    _addressLabel.textAlignment = UITextAlignmentLeft;
    
    _nameLabel.lineBreakMode = UILineBreakModeWordWrap;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _summaryLabel.lineBreakMode = UILineBreakModeWordWrap;
    _activityLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _lastActivityLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _addressLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    _nameLabel.numberOfLines = 2;
    _timestampLabel.numberOfLines = 1;
    _summaryLabel.numberOfLines = 8;
    _activityLabel.numberOfLines = 1;
    _lastActivityLabel.numberOfLines = 1;
    _addressLabel.numberOfLines = 1;
    
    _unreadImageView = [[UIImageView alloc] initWithImage:_unreadImage];
    
    [self.contentView addSubview:_unreadImageView];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_timestampLabel];
    [self.contentView addSubview:_summaryLabel];
    [self.contentView addSubview:_activityLabel];
    [self.contentView addSubview:_lastActivityLabel];
    [self.contentView addSubview:_addressLabel];
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
  
  _moogleFrameView.left += _unreadImageView.right;
  _moogleImageView.left = _moogleFrameView.left + SPACING_X;
  _imageLoadingIndicator.left += _unreadImageView.right;
  
  left = _moogleFrameView.right;
  
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
  
  // Row 3
  if ([_addressLabel.text length] > 0) {
    // Address
    textWidth = self.contentView.width - left - SPACING_X;
    [_addressLabel sizeToFitFixedWidth:textWidth];
    _addressLabel.left = left;
    _addressLabel.top = top;  
    
    top = _addressLabel.bottom;
  }
  
  // Last Activity
  textWidth = self.contentView.width - left - SPACING_X;
  [_lastActivityLabel sizeToFitFixedWidth:textWidth];
  _lastActivityLabel.left = left;
  _lastActivityLabel.top = top;  
  
  // Row 4
  top = _lastActivityLabel.bottom;
  
  // Summary Label
  textWidth = self.contentView.width - left - SPACING_X;
  [_summaryLabel sizeToFitFixedWidth:textWidth];
  _summaryLabel.left = left;
  _summaryLabel.top = top;
  
  // Row 5
  top = _summaryLabel.bottom;
  
  // Activity Label
  textWidth = self.contentView.width - left - SPACING_X;
  [_activityLabel sizeToFitFixedWidth:textWidth];
  _activityLabel.left = left;
  _activityLabel.top = top;
  
  // Set desired height
  _desiredHeight = _activityLabel.bottom + MARGIN_Y;
  
  if (_desiredHeight < _moogleFrameView.bottom) {
    _desiredHeight = _moogleFrameView.bottom + MARGIN_Y;
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _timestampLabel.text = nil;
  _summaryLabel.text = nil;
  _activityLabel.text = nil;
  _lastActivityLabel.text = nil;
  _addressLabel.text = nil;
  _unreadImageView.hidden = NO;
  [_moogleImageView unloadImage];
}

- (void)fillCellWithObject:(id)object {
  Place *place = (Place *)object;
  _nameLabel.text = place.name;
  _timestampLabel.text = [place.timestamp humanIntervalSinceNow];
  _summaryLabel.text = [NSString stringWithFormat:@"Friends: %@", place.friendFirstNames];
  _activityLabel.text = ([place.activityCount integerValue] <= 1) ? [NSString stringWithFormat:@"%@ piece of the story", place.activityCount] : [NSString stringWithFormat:@"%@ pieces of the story", place.activityCount];
  
  if ([place.kupoType integerValue] == 0) {
    _lastActivityLabel.text = [NSString stringWithFormat:@"%@ checked in here", place.authorName];
  } else if ([place.kupoType integerValue] == 1) {
    if ([place.hasPhoto boolValue]) {
      if ([place.hasVideo boolValue]) {
        _lastActivityLabel.text = [NSString stringWithFormat:@"%@ shared a video", place.authorName];
      } else {
        _lastActivityLabel.text = [NSString stringWithFormat:@"%@ shared a photo", place.authorName];
      }
    } else {
      _lastActivityLabel.text = [NSString stringWithFormat:@"%@ posted a comment", place.authorName];
    }
  }
  
  if (place.address) {
    _addressLabel.text = place.address;
  }
  
//  _moogleImageView.urlPath = place.pictureUrl;
  _moogleImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", place.authorId];
  
  if ([place.isRead boolValue]) {
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
  RELEASE_SAFELY(_lastActivityLabel);
  RELEASE_SAFELY(_addressLabel);
  [super dealloc];
}

@end

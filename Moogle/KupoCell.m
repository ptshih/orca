//
//  KupoCell.m
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 13.0
#define COMMENT_FONT_SIZE 18.0
#define TIMESTAMP_FONT_SIZE 12.0
#define PHOTO_SIZE 100.0
#define PHOTO_SPACING 5.0

@implementation KupoCell

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
    _commentLabel.font = [UIFont systemFontOfSize:COMMENT_FONT_SIZE];
    
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
  CGFloat left = MARGIN_X;
  CGFloat textWidth = 0.0;
  
  left = _moogleFrameView.right;
  
  // Row 1
  
  // Timestamp Label
  textWidth = self.contentView.width - left - SPACING_X;
  [_timestampLabel sizeToFitFixedWidth:textWidth];
  _timestampLabel.left = self.contentView.width - _timestampLabel.width - SPACING_X;
  _timestampLabel.top = top;
  
  // Name Label
  textWidth = self.contentView.width - left - _timestampLabel.width - SPACING_X * 2;
  [_nameLabel sizeToFitFixedWidth:textWidth];
  _nameLabel.left = left;
  _nameLabel.top = top;
  
  // Row 2
  top = _nameLabel.bottom;
  
  // Status Label
  textWidth = self.contentView.width - left - SPACING_X;
  [_statusLabel sizeToFitFixedWidth:textWidth];
  _statusLabel.left = left;
  _statusLabel.top = top;
  
  // Row 3
  top = _statusLabel.bottom;
  
  // Comment Label
  textWidth = self.contentView.width - left - SPACING_X;
  [_commentLabel sizeToFitFixedWidth:textWidth];
  _commentLabel.left = left;
  _commentLabel.top = top;
  
  if (_photoImageView.urlPath) {  
    // Row 4 (conditional)
    top = _commentLabel.bottom;
    
    // Photo Image View
    _photoImageView.left = left;
    _photoImageView.top = top + PHOTO_SPACING;
    _photoImageView.width = PHOTO_SIZE;
    _photoImageView.height = PHOTO_SIZE;
    _photoImageView.layer.masksToBounds = YES;
    _photoImageView.layer.cornerRadius = 4.0;
    
    // Set desired height
    _desiredHeight = _photoImageView.bottom + MARGIN_Y;
  } else {
    // Set desired height
    _desiredHeight = _commentLabel.bottom + MARGIN_Y;
  }
  
  if (_desiredHeight < _moogleFrameView.bottom) {
    _desiredHeight = _moogleFrameView.bottom + MARGIN_Y;
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _timestampLabel.text = nil;
  _statusLabel.text = nil;
  _commentLabel.text = nil;
  [_moogleImageView unloadImage];
  [_photoImageView unloadImage];
}

- (void)fillCellWithObject:(id)object {
  Kupo *kupo = (Kupo *)object;
  _nameLabel.text = kupo.authorName;
  _timestampLabel.text = [kupo.timestamp humanIntervalSinceNow];
  
  if ([_commentLabel.text length] > 0) {
    _commentLabel.text = [NSString stringWithFormat:@"\"%@\"", kupo.comment];
  }
  
  _moogleImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", kupo.authorId];
  [_moogleImageView loadImage];
  
  if ([kupo.kupoType isEqualToString:@"checkin"]) {
    _statusLabel.text = [NSString stringWithFormat:@"Checked in here via Facebook"];
  }
  
  if ([kupo.hasPhoto boolValue]) {
    _photoImageView.urlPath = [NSString stringWithFormat:@"%@/%@/thumb/image.png", S3_BASE_URL, kupo.id];
    [_photoImageView loadImage];
  }
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
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
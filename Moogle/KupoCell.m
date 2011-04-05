//
//  KupoCell.m
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 12.0
#define COMMENT_FONT_SIZE 16.0
#define TIMESTAMP_FONT_SIZE 12.0
#define PHOTO_SIZE 100.0
#define PHOTO_SPACING 5.0

static UIImage *_quoteImage = nil;

@implementation KupoCell

+ (void)initialize {
  _quoteImage = [[UIImage imageNamed:@"quote_mark.png"] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _hasPhoto = NO;
    
    _nameLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    _statusLabel = [[UILabel alloc] init];
    _commentLabel = [[UILabel alloc] init];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.backgroundColor = [UIColor clearColor];
    _commentLabel.backgroundColor = [UIColor clearColor];
    
    _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE];
    _timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE];
    _statusLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE];
    _commentLabel.font = [UIFont fontWithName:@"Futura-Medium" size:COMMENT_FONT_SIZE];
    
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
    
    _quoteImageView = [[UIImageView alloc] initWithImage:_quoteImage];
    _quoteImageView.hidden = YES;
    [self.contentView addSubview:_quoteImageView];
    
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
  if ([_commentLabel.text length] > 0) {
    _quoteImageView.hidden = NO;
    _quoteImageView.left = left;
    _quoteImageView.top = top + MARGIN_Y;
  } else {
    _quoteImageView.hidden = YES;
  }
  
  textWidth = self.contentView.width - _quoteImageView.width - MARGIN_X - left - SPACING_X;
  [_commentLabel sizeToFitFixedWidth:textWidth];
  _commentLabel.left = left + _quoteImageView.width + MARGIN_X;
  _commentLabel.top = top + 2;
  
  top = _commentLabel.bottom;
  
  if (_photoImageView.urlPath) {  
    // Photo Image View
    _photoImageView.left = left;
    _photoImageView.top = top + PHOTO_SPACING;
    _photoImageView.width = PHOTO_SIZE;
    _photoImageView.height = PHOTO_SIZE;
    _photoImageView.layer.masksToBounds = YES;
    _photoImageView.layer.cornerRadius = 4.0;
    
    top = _photoImageView.bottom;
  } else {
    top = _commentLabel.bottom;
  }
  
  // Set desired height
  _desiredHeight = top + MARGIN_Y;
  
  if (_desiredHeight < _moogleFrameView.bottom) {
    _desiredHeight = _moogleFrameView.bottom + MARGIN_Y;
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _hasPhoto = NO;
  _nameLabel.text = nil;
  _timestampLabel.text = nil;
  _statusLabel.text = nil;
  _commentLabel.text = nil;
  [_moogleImageView unloadImage];
  [_photoImageView unloadImage];
  _quoteImageView.hidden = YES;
}

- (void)fillCellWithObject:(id)object {
  Kupo *kupo = (Kupo *)object;
  _nameLabel.text = kupo.authorName;
  _timestampLabel.text = [kupo.timestamp humanIntervalSinceNow];
  
  if ([kupo.comment length] > 0) {
    _commentLabel.text = [NSString stringWithFormat:@"%@", kupo.comment];
  }
  
  _moogleImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", kupo.authorId];
  
  if ([kupo.kupoType integerValue] == 0) {
    if (kupo.tagged) {
      _statusLabel.text = [NSString stringWithFormat:@"Checked in via Facebook with %@", kupo.tagged];
    } else {
      _statusLabel.text = [NSString stringWithFormat:@"Checked in via Facebook"];
    }
  }
  
  if ([kupo.hasPhoto boolValue]) {
    _hasPhoto = YES;
    _photoImageView.urlPath = [NSString stringWithFormat:@"%@/%@/thumb/image.png", S3_PHOTOS_URL, kupo.id];
    
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
  } else {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
}

- (void)loadPhoto {
  if (_hasPhoto) {
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
  RELEASE_SAFELY(_quoteImageView);
  [super dealloc];
}

@end
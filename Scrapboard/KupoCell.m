//
//  ScrapboardCell.m
//  Scrapboard
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 12.0
#define MESSAGE_FONT_SIZE 16.0
#define TIMESTAMP_FONT_SIZE 12.0
#define PHOTO_SIZE 100.0
#define PHOTO_SPACING 5.0
#define QUOTE_SPACING 5.0

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
    _messageLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    
    _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE];
    _messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MESSAGE_FONT_SIZE];
    _timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE];
    
    _timestampLabel.textAlignment = UITextAlignmentRight;
    _timestampLabel.textColor = GRAY_COLOR;
    
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    _nameLabel.numberOfLines = 1;
    _messageLabel.numberOfLines = 0;
    _timestampLabel.numberOfLines = 1;
    
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_messageLabel];
    [self.contentView addSubview:_timestampLabel];
    
    _quoteImageView = [[UIImageView alloc] initWithImage:_quoteImage];
    
    _photoImageView = [[PSImageView alloc] initWithFrame:CGRectMake(0, 0, PHOTO_SIZE, PHOTO_SIZE)];
    _photoImageView.placeholderImage = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X + 60;
  CGFloat textWidth = self.contentView.width - 60 - MARGIN_X * 2;
  
  // Row 1
  
  // Timestamp Label
  _timestampLabel.text = [_kupo.timestamp humanIntervalSinceNow];
  [_timestampLabel sizeToFitFixedWidth:textWidth];
  _timestampLabel.left = self.contentView.width - _timestampLabel.width - MARGIN_X;
  _timestampLabel.top = top;
  
  // Name Label
  _nameLabel.text = _kupo.authorName;
  [_nameLabel sizeToFitFixedWidth:(textWidth - _timestampLabel.width - MARGIN_X)];
  _nameLabel.left = left;
  _nameLabel.top = top;
  top = _nameLabel.bottom;
  
  // Row 2

  // Message Label
  if ([_kupo.message length] > 0) {
    [self.contentView addSubview:_quoteImageView];
    _quoteImageView.left = left;
    _quoteImageView.top = top;
    
    _messageLabel.text = _kupo.message;
    [_messageLabel sizeToFitFixedWidth:textWidth - _quoteImageView.width - QUOTE_SPACING];
    _messageLabel.left = left + _quoteImageView.width + QUOTE_SPACING;
    _messageLabel.top = top;
    top = _messageLabel.bottom;
  } else {
    [_quoteImageView removeFromSuperview];
  }
  
  // Row 3
  
  // Optional Photo Thumbnail
  if (_hasPhoto) {
    [self.contentView addSubview:_photoImageView];
    _photoImageView.left = left;
    _photoImageView.top = top + PHOTO_SPACING;
    _photoImageView.width = PHOTO_SIZE;
    _photoImageView.height = PHOTO_SIZE;
    _photoImageView.layer.masksToBounds = YES;
    _photoImageView.layer.cornerRadius = 10.0;
  } else {
    [_photoImageView removeFromSuperview];
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _hasPhoto = NO;
  _nameLabel.text = nil;
  _messageLabel.text = nil;
  _timestampLabel.text = nil;
  [_photoImageView unloadImage];
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object {
  Kupo *kupo = (Kupo *)object;
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X + 60; // image
  CGFloat width = [[self class] rowWidth] - left - MARGIN_X;
  CGSize constrainedSize = CGSizeMake(width, INT_MAX);
  CGSize size = CGSizeZero;
  
  CGFloat desiredHeight = top;
  
  // Name and Timestamp
  size = [[kupo.timestamp humanIntervalSinceNow] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
  constrainedSize = CGSizeMake(width - size.width - MARGIN_X, INT_MAX);
  
  size = [kupo.authorName sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
  desiredHeight += size.height;
  
  constrainedSize = CGSizeMake(width, INT_MAX);
  
  // Message
  size = [kupo.message sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:MESSAGE_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
  desiredHeight += size.height;

  
  if ([kupo.hasPhoto boolValue]) {
    desiredHeight += 110.0;
  }
  
  desiredHeight += MARGIN_Y;
  
  // If cell is shorter than image, set min height
  if (desiredHeight < 60) {
    desiredHeight = 60;
  }
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Kupo *kupo = (Kupo *)object;
  if (_kupo) RELEASE_SAFELY(_kupo);
  _kupo = [kupo retain];
  
  _psImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", kupo.authorFacebookId];
  
  if ([kupo.hasPhoto boolValue]) {
    _hasPhoto = YES;
    _photoImageView.urlPath = [NSString stringWithFormat:@"%@/%@/thumb/%@", S3_PHOTOS_URL, kupo.id, kupo.photoFileName];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
  } else {
    _hasPhoto = NO;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
}

- (void)loadPhoto {
  if (_hasPhoto) {
    [_photoImageView loadImage];
  }
}

+ (PSCellType)cellType {
  return PSCellTypePlain;
}

- (void)dealloc {
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_messageLabel);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_kupo);
  RELEASE_SAFELY(_quoteImageView);
  RELEASE_SAFELY(_photoImageView);
  [super dealloc];
}

@end
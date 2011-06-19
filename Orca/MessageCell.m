//
//  MessageCell.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"
#import "PSURLCacheImageView.h"

//UILabel *_nameLabel;
//UILabel *_messageLabel;
//UILabel *_timestampLabel;

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    _nameLabel = [[UILabel alloc] init];
    _messageLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    
    // Background Color
    _nameLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    
    // Font
    _nameLabel.font = TITLE_FONT;
    _messageLabel.font = NORMAL_FONT;
    _timestampLabel.font = TIMESTAMP_FONT;
    
    // Text Color
    _nameLabel.textColor = [UIColor darkTextColor];
    _messageLabel.textColor = [UIColor darkTextColor];
    _timestampLabel.textColor = [UIColor darkTextColor];
    
    // Text Alignment
    _timestampLabel.textAlignment = UITextAlignmentRight;
    
    // Line Break Mode
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Number of Lines
    _nameLabel.numberOfLines = 1;
    _messageLabel.numberOfLines = 0;
    _timestampLabel.numberOfLines = 1;
    
    // Shadows
//    _nameLabel.shadowColor = [UIColor whiteColor];
//    _nameLabel.shadowOffset = CGSizeMake(0, -1);
    
    // Photo
    _photoView = [[PSURLCacheImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 120)];
    _photoView.hidden = YES;
    [self.contentView addSubview:_photoView];
    
    // Add labels
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_messageLabel];
    [self.contentView addSubview:_timestampLabel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhotoFromNotification:) name:kMessageCellReloadPhoto object:nil];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _messageLabel.text = nil;
  _timestampLabel.text = nil;
  [_photoView unloadImage];
  _photoView.hidden = YES;
  _photoWidth = 0;
  _photoHeight = 0;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = _psFrameView.right;
  CGFloat textWidth = self.contentView.width - MARGIN_X - left;
  CGSize desiredSize = CGSizeZero;
  
  // Timestamp
  desiredSize = [UILabel sizeForText:_timestampLabel.text width:textWidth font:_timestampLabel.font numberOfLines:_timestampLabel.numberOfLines lineBreakMode:_timestampLabel.lineBreakMode];
  _timestampLabel.width = desiredSize.width;
  _timestampLabel.height = desiredSize.height;
  _timestampLabel.top = top;
  _timestampLabel.left = self.contentView.width - MARGIN_X - _timestampLabel.width;
  
  // Name
  desiredSize = [UILabel sizeForText:_nameLabel.text width:(textWidth - _timestampLabel.width - MARGIN_X) font:_nameLabel.font numberOfLines:_nameLabel.numberOfLines lineBreakMode:_nameLabel.lineBreakMode];
  _nameLabel.width = desiredSize.width;
  _nameLabel.height = desiredSize.height;
  _nameLabel.top = top;
  _nameLabel.left = left;
  
  top = _nameLabel.bottom;
  
  // Message
  desiredSize = [UILabel sizeForText:_messageLabel.text width:textWidth font:_messageLabel.font numberOfLines:_messageLabel.numberOfLines lineBreakMode:_messageLabel.lineBreakMode];
  _messageLabel.width = desiredSize.width;
  _messageLabel.height = desiredSize.height;
  _messageLabel.top = top;
  _messageLabel.left = left;
  
  top = _messageLabel.bottom;
  
  // Photo
  if (_photoView.urlPath) {
    top += 5;
    _photoView.hidden = NO;
    _photoView.top = top;
    _photoView.left = left;
  }
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  Message *message = (Message *)object;
  
  CGSize desiredSize = CGSizeZero;
  CGFloat textWidth = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - MARGIN_X - IMAGE_OFFSET; // minus image
  
  CGFloat desiredHeight = 0;
  
  // Top margin
  desiredHeight += MARGIN_Y;
  
  // Name
  desiredHeight += 21; // desiredHeight from Name Label
  
  // Message
  desiredSize = [UILabel sizeForText:message.message width:textWidth font:NORMAL_FONT numberOfLines:0 lineBreakMode:UILineBreakModeWordWrap];
  desiredHeight += desiredSize.height;
  
  // Optional Photo
  if (message.attachmentUrl) {
    desiredHeight += 130;
  }
  
  // Bottom margin
  desiredHeight += MARGIN_Y;
  
  if (desiredHeight < 60) {
    desiredHeight = 60;
  }
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Message *message = (Message *)object;
  _message = message;
  
  // Labels
  _nameLabel.text = message.fromName;
  _messageLabel.text = message.message;
  _timestampLabel.text = [NSDate stringForDisplayFromDate:message.timestamp];
  
  // Profile Picture
  _psImageView.urlPath = message.fromPictureUrl;
  
  // Photo
  _photoView.urlPath = message.attachmentUrl;
  [_photoView loadImageAndDownload:NO];
}

- (void)loadPhoto {
  if (_photoView.urlPath) {
    [_photoView loadImageAndDownload:YES];
  }
}

- (void)loadPhotoFromNotification:(NSNotification *)notification {
  NSString *sequence = [[notification userInfo] objectForKey:@"sequence"];
  if (sequence && [sequence isEqualToString:_message.sequence]) {
    [self loadPhoto];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kMessageCellReloadPhoto object:nil];
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_messageLabel);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_photoView);
  [super dealloc];
}

@end

//
//  MessageCell.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"

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
    _timestampLabel.font = SUBTITLE_FONT;
    
    // Text Color
    _nameLabel.textColor = [UIColor darkTextColor];
    _messageLabel.textColor = [UIColor darkTextColor];
    _timestampLabel.textColor = [UIColor darkTextColor];
    
    // Text Alignment
    _timestampLabel.textAlignment = UITextAlignmentRight;
    
    // Line Break Mode
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Number of Lines
    _nameLabel.numberOfLines = 1;
    _messageLabel.numberOfLines = 1;
    _timestampLabel.numberOfLines = 1;
    
    // Shadows
    _nameLabel.shadowColor = [UIColor whiteColor];
    _nameLabel.shadowOffset = CGSizeMake(0, -1);
    
    // Add labels
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_messageLabel];
    [self.contentView addSubview:_timestampLabel];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _messageLabel.text = nil;
  _timestampLabel.text = nil;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X + _psFrameView.right;
  CGFloat textWidth = self.contentView.width - MARGIN_X - left;
  CGSize desiredSize = CGSizeZero;
  
  // Timestamp
  desiredSize = [UILabel sizeForText:_timestampLabel.text width:textWidth font:_timestampLabel.font numberOfLines:1 lineBreakMode:_timestampLabel.lineBreakMode];
  _timestampLabel.width = desiredSize.width;
  _timestampLabel.height = desiredSize.height;
  _timestampLabel.top = top;
  _timestampLabel.left = self.contentView.width - MARGIN_X - _timestampLabel.width;
  
  // Name
  desiredSize = [UILabel sizeForText:_nameLabel.text width:(textWidth - _timestampLabel.width - MARGIN_X) font:_nameLabel.font numberOfLines:1 lineBreakMode:_nameLabel.lineBreakMode];
  _nameLabel.width = desiredSize.width;
  _nameLabel.height = desiredSize.height;
  _nameLabel.top = top;
  _nameLabel.left = left;
  
  top = _nameLabel.bottom;
  
  // Message
  desiredSize = [UILabel sizeForText:_messageLabel.text width:textWidth font:_messageLabel.font numberOfLines:1 lineBreakMode:_messageLabel.lineBreakMode];
  _messageLabel.width = desiredSize.width;
  _messageLabel.height = desiredSize.height;
  _messageLabel.top = top;
  _messageLabel.left = left;
  
  top = _messageLabel.bottom;
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return 60;
}

- (void)fillCellWithObject:(id)object {
  Message *message = (Message *)object;
  _message = message;
  
  // Labels
  _nameLabel.text = message.fromName;
  _messageLabel.text = message.message;
  _timestampLabel.text = [message.timestamp stringDaysAgo];
  
  // Profile Picture
  _psImageView.urlPath = message.fromPictureUrl;
}

- (void)dealloc {
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_messageLabel);
  RELEASE_SAFELY(_timestampLabel);
  [super dealloc];
}

@end

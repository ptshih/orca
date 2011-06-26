//
//  PodCell.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PodCell.h"

#define POD_CELL_HEIGHT 70.0
#define POD_UNREAD_OFFSET 20.0

static UIImage *_unreadImage = nil;

@implementation PodCell

+ (void)initialize {
  _unreadImage = [[UIImage imageNamed:@"unread.png"] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timestampLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _participantsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    // Background Color
    _nameLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    _participantsLabel.backgroundColor = [UIColor clearColor];
    
    // Font
    _nameLabel.font = TITLE_FONT;
    _messageLabel.font = NORMAL_FONT;
    _timestampLabel.font = TIMESTAMP_FONT;
    _participantsLabel.font = SUBTITLE_FONT;
    
    // Text Color
    _nameLabel.textColor = [UIColor darkTextColor];
    _messageLabel.textColor = [UIColor darkTextColor];
    _timestampLabel.textColor = [UIColor darkTextColor];
    _participantsLabel.textColor = [UIColor darkTextColor];
    
    // Text Alignment
    _timestampLabel.textAlignment = UITextAlignmentRight;
    
    // Line Break Mode
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _participantsLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Number of Lines
    _nameLabel.numberOfLines = 1;
    _messageLabel.numberOfLines = 1;
    _timestampLabel.numberOfLines = 1;
    _participantsLabel.numberOfLines = 1;
    
    // Shadows
//    _nameLabel.shadowColor = [UIColor whiteColor];
//    _nameLabel.shadowOffset = CGSizeMake(0, -1);
    
    // Add labels
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_messageLabel];
    [self.contentView addSubview:_timestampLabel];
    [self.contentView addSubview:_participantsLabel];
    
    // Unread
    _unreadImageView = [[UIImageView alloc] initWithImage:_unreadImage];
    _unreadImageView.frame = CGRectMake(0, 0, _unreadImage.size.width, _unreadImage.size.height);
    _unreadImageView.hidden = YES;
    [self.contentView addSubview:_unreadImageView];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _messageLabel.text = nil;
  _timestampLabel.text = nil;
  _participantsLabel.text = nil;
  _unreadImageView.hidden = YES;
}

- (void)layoutSubviews {
  [super layoutSubviews];
    
  CGFloat top = MARGIN_Y;
  CGFloat left = POD_UNREAD_OFFSET;
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
  
  top = _messageLabel.bottom + 2.0;
  
  // Participants
  desiredSize = [UILabel sizeForText:_participantsLabel.text width:textWidth font:_participantsLabel.font numberOfLines:1 lineBreakMode:_participantsLabel.lineBreakMode];
  _participantsLabel.width = desiredSize.width;
  _participantsLabel.height = desiredSize.height;
  _participantsLabel.top = top;
  _participantsLabel.left = left;
  
  top = _participantsLabel.bottom;
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return POD_CELL_HEIGHT;
}

- (void)fillCellWithObject:(id)object {
  Pod *pod = (Pod *)object;
  _pod = pod;
  
  // Labels
  _nameLabel.text = pod.name;
  _messageLabel.text = [NSString stringWithFormat:@"%@: %@", pod.fromName, [[pod meta] objectForKey:@"message"]];
  _timestampLabel.text = [NSDate stringForDisplayFromDate:pod.timestamp];
  _participantsLabel.text = [NSString stringWithFormat:@"%@", pod.participants];
  _unreadImageView.hidden = [pod.unread boolValue] ? NO : YES;
}

- (void)dealloc {
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_messageLabel);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_participantsLabel);
  RELEASE_SAFELY(_unreadImageView);
  [super dealloc];
}

@end

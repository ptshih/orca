//
//  EventCell.m
//  Kupo
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 12.0
#define TIMESTAMP_FONT_SIZE 12.0
#define ADDRESS_FONT_SIZE 12.0
#define LAST_ACTIVITY_FONT_SIZE 13.0
#define UNREAD_WIDTH 5.0
#define FRIEND_PICTURE_MARGIN 2.0

@implementation EventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Labels
    _tagLabel = [[UILabel alloc] init];
    _nameLabel = [[UILabel alloc] init];
    _lastActivityLabel = [[UILabel alloc] init];
    _friendsLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    
    _tagLabel.backgroundColor = [UIColor clearColor];
    _nameLabel.backgroundColor = [UIColor clearColor];
    _lastActivityLabel.backgroundColor = [UIColor clearColor];
    _friendsLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    
    _tagLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:CELL_FONT_SIZE];
    _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE];
    _lastActivityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:CELL_FONT_SIZE];
    _friendsLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE];
    _timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE];
    
    _timestampLabel.textAlignment = UITextAlignmentRight;
    _timestampLabel.textColor = GRAY_COLOR;
    
    _tagLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _nameLabel.lineBreakMode = UILineBreakModeWordWrap;
    _lastActivityLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _friendsLabel.lineBreakMode = UILineBreakModeWordWrap;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    _tagLabel.numberOfLines = 1;
    _nameLabel.numberOfLines = 0;
    _lastActivityLabel.numberOfLines = 1;
    _friendsLabel.numberOfLines = 0;
    _timestampLabel.numberOfLines = 1;
    
    [self.contentView addSubview:_tagLabel];
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_lastActivityLabel];
    [self.contentView addSubview:_friendsLabel];
    [self.contentView addSubview:_timestampLabel];
    
    // Friends Pictures
    _friendIds = [[NSMutableArray alloc] initWithCapacity:6];
    _friendPictureArray = [[NSMutableArray alloc] initWithCapacity:6];
    PSImageView *profileImage = nil;
    for (int i=0;i<6;i++) {
      profileImage = [[[PSImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)] autorelease];
      [_friendPictureArray addObject:profileImage];
    }
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
  _timestampLabel.text = [_event.timestamp humanIntervalSinceNow];
  [_timestampLabel sizeToFitFixedWidth:textWidth];
  _timestampLabel.left = self.contentView.width - _timestampLabel.width - MARGIN_X;
  _timestampLabel.top = top;
  
  // Name Label
  _nameLabel.text = _event.name;
  [_nameLabel sizeToFitFixedWidth:(textWidth - _timestampLabel.width - MARGIN_X)];
  _nameLabel.left = left;
  _nameLabel.top = top;
  
  // Row 2
  top = _nameLabel.bottom;
  
  // Tag Label
  _tagLabel.text = _event.tag;
  [_tagLabel sizeToFitFixedWidth:textWidth];
  _tagLabel.left = left;
  _tagLabel.top = top;
  
  // Row 3
  top = _tagLabel.bottom;
  
  // Last Activity
  _lastActivityLabel.text = _event.lastActivity;
  [_lastActivityLabel sizeToFitFixedWidth:textWidth];
  _lastActivityLabel.left = left;
  _lastActivityLabel.top = top;  
  
  // Row 4
  top = _lastActivityLabel.bottom;
  
  // Friend activity pictures
  if (_event.friendIds && [[_event.friendIds componentsSeparatedByString:@","] count] > 1) {
    int i = 0;
    for (PSImageView *picture in _friendPictureArray) {
      picture.top = top + FRIEND_PICTURE_MARGIN;
      picture.left = left + i * picture.width + i * MARGIN_X;
      [self.contentView addSubview:picture];
      i++;
    }
    
    top += 30 + FRIEND_PICTURE_MARGIN * 2;
    
    // Friends Participants
    _friendsLabel.text = _event.friendFirstNames;
    [_friendsLabel sizeToFitFixedWidth:textWidth];
    _friendsLabel.left = left;
    _friendsLabel.top = top;
  }
  
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [_psImageView unloadImage];
  for (PSImageView *picture in _friendPictureArray) {
    [picture unloadImage];
  }
  _tagLabel.text = nil;
  _nameLabel.text = nil;
  _lastActivityLabel.text = nil;
  _friendsLabel.text = nil;
  _timestampLabel.text = nil;
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object {
  Event *event = (Event *)object;
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X + 60; // image
  CGFloat width = [[self class] rowWidth] - left - MARGIN_X;
  CGSize constrainedSize = CGSizeMake(width, INT_MAX);
  CGSize size = CGSizeZero;
  
  CGFloat desiredHeight = top;
  
  // Name and Timestamp
  size = [[event.timestamp humanIntervalSinceNow] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
  constrainedSize = CGSizeMake(width - size.width - MARGIN_X, INT_MAX);
  
  size = [event.name sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
  desiredHeight += size.height;
  
  constrainedSize = CGSizeMake(width, INT_MAX);
  
  // Tag
  size = [event.tag sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:CELL_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
  desiredHeight += size.height;
  
  // Last Activity
  if (event.lastActivity && [event.lastActivity length] > 0) {
    size = [event.lastActivity sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:CELL_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
    desiredHeight += size.height;
  }
  
  // Friend Pictures
  if (event.friendIds && [[event.friendIds componentsSeparatedByString:@","] count] > 1) {
    desiredHeight += 30 + FRIEND_PICTURE_MARGIN * 2;
    
    // Friend Names
    if (event.friendFirstNames && [event.friendFirstNames length] > 0) {
      size = [event.friendFirstNames sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
      desiredHeight += size.height;
    }
  }
  
  desiredHeight += MARGIN_Y;
  
  // If cell is shorter than image, set min height
  if (desiredHeight < 60) {
    desiredHeight = 60;
  }

  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Event *event = (Event *)object;
  if (_event) RELEASE_SAFELY(_event);
  _event = [event retain];
  
//  _psImageView.urlPath = event.pictureUrl;
  _psImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", event.authorFacebookId];
  
  // Activity Friends Photos
  [_friendIds removeAllObjects];
  [_friendIds addObjectsFromArray:[event.friendIds componentsSeparatedByString:@","]];
  [_friendIds removeObject:event.authorId];
  
  
  int i = 0;
  for (PSImageView *picture in _friendPictureArray) {
    if (i < [_friendIds count]) {
      [picture setUrlPath:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [_friendIds objectAtIndex:i]]];
    } else {
      [picture unloadImage];
    }
    i++;
  }
}

- (void)loadFriendPictures {
  if ([_friendIds count] > 1) {
    for (PSImageView *picture in _friendPictureArray) {
      [picture loadImage];
    }
  }
}

+ (PSCellType)cellType {
  return PSCellTypePlain;
}

- (void)dealloc {
  RELEASE_SAFELY(_tagLabel);
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_lastActivityLabel);
  RELEASE_SAFELY(_friendsLabel);
  RELEASE_SAFELY(_timestampLabel);
  
  RELEASE_SAFELY(_friendIds);
  RELEASE_SAFELY(_friendPictureArray);
  RELEASE_SAFELY(_event);
  [super dealloc];
}

@end

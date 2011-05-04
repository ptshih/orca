//
//  AlbumCell.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumCell.h"

#define NAME_FONT_SIZE 14.0
#define MESSAGE_FONT_SIZE 16.0
#define TIMESTAMP_FONT_SIZE 12.0

@implementation AlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _nameLabel = [[UILabel alloc] init];
    _messageLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    
    _nameLabel.backgroundColor = [UIColor clearColor];
    _messageLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    
    _nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE];
    _messageLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:MESSAGE_FONT_SIZE];
    _timestampLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE];
    
    _nameLabel.textColor = [UIColor whiteColor];
    _messageLabel.textColor = [UIColor whiteColor];
    _timestampLabel.textAlignment = UITextAlignmentRight;
    _timestampLabel.textColor = GRAY_COLOR;
    
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _messageLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    _nameLabel.numberOfLines = 1;
    _messageLabel.numberOfLines = 1;
    _timestampLabel.numberOfLines = 1;
    
    // Bubble View
    _bubbleView = [[UIView alloc] init];
    
    _bubbleImageView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:25]];
    [_bubbleView addSubview:_bubbleImageView];
    
    _photoView = [[PSImageView alloc] init];
    _photoView.shouldScale = YES;
    [_bubbleView addSubview:_photoView];
    
    [_bubbleView addSubview:_nameLabel];
    [_bubbleView addSubview:_messageLabel];
    [_bubbleView addSubview:_timestampLabel];
    
    [self.contentView addSubview:_bubbleView];
    
    // Activity View
    _activityView = [[UIView alloc] init];
    
    _activityLabel = [[UILabel alloc] init];
    [_activityView addSubview:_activityLabel];
    
    [self.contentView addSubview:_activityView];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X + 60;
  CGFloat textWidth = self.contentView.width - 60 - MARGIN_X * 2;
  
  // Bubble
  _bubbleView.left = left;
  _bubbleView.top = top;
  _bubbleView.width = textWidth;
  _bubbleView.height = 80.0;
  
  _bubbleImageView.frame = _bubbleView.bounds;
  
  // Photo
  _photoView.frame = CGRectMake(10, 5, _bubbleView.width - 15, _bubbleView.height - 10);

  // Name
  _nameLabel.top = 5;
  _nameLabel.left = 15;
  _nameLabel.width = _bubbleView.width - 25;
  _nameLabel.height = 20;
  
  // Message
  _messageLabel.top = _bubbleView.bottom - 10 - 20;
  _messageLabel.left = 15;
  _messageLabel.width = _bubbleView.width - 25;
  _messageLabel.height = 20;
  
  // Activity
  _activityView.top = _bubbleView.bottom + 5;
  _activityView.left = left;
  _activityView.width = textWidth;
  _activityView.height = 20;
  
  _activityLabel.frame = _activityView.bounds;
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  Album *album = (Album *)object;
  return 120.0;
}

- (void)fillCellWithObject:(id)object {
  Album *album = (Album *)object;
  
  _psImageView.urlPath = album.userPictureUrl;
  
  _photoView.urlPath = album.photoUrl;
  
  _nameLabel.text = album.name;
  _messageLabel.text = album.message;
  _timestampLabel.text = [album.timestamp humanIntervalSinceNow];
  
  // Activity
  _activityLabel.text = [NSString stringWithFormat:@"%@ photos, %@ likes, %@ comments", album.photoCount, album.likeCount, album.commentCount];
}

- (void)loadPhoto {
  [_photoView loadImage];
}

- (void)dealloc {
  RELEASE_SAFELY(_bubbleView);
  RELEASE_SAFELY(_bubbleImageView);
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_messageLabel);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_activityView);
  RELEASE_SAFELY(_activityLabel);
  [super dealloc];
}

@end

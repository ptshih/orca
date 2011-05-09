//
//  AlbumCell.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumCell.h"

#define NAME_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]
#define MESSAGE_FONT [UIFont fontWithName:@"HelveticaNeue" size:16.0]
#define TIMESTAMP_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0]
#define ACTIVITY_FONT [UIFont fontWithName:@"HelveticaNeue" size:14.0]

#define BUBBLE_HEIGHT 80.0
#define BUBBLE_MARGIN 5.0

#define ACTIVITY_HEIGHT 24.0

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
    
    _nameLabel.font = NAME_FONT;
    _messageLabel.font = MESSAGE_FONT;
    _timestampLabel.font = TIMESTAMP_FONT;
    
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
    _bubbleView = [[UIView alloc] initWithFrame:CGRectMake(_psFrameView.right, MARGIN_Y, self.contentView.width - _psFrameView.width - MARGIN_X * 2 , BUBBLE_HEIGHT)];
    
    // Bubble BG
    UIImageView *bubbleBg = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"bubble.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:25]] autorelease];
    bubbleBg.frame = _bubbleView.bounds;
    [_bubbleView addSubview:bubbleBg];
    
    // Bubble Photo
    _photoView = [[PSImageView alloc] initWithFrame:CGRectMake(BUBBLE_MARGIN * 2, BUBBLE_MARGIN, _bubbleView.width - BUBBLE_MARGIN * 3, _bubbleView.height - BUBBLE_MARGIN * 2)];
    _photoView.shouldScale = YES;
    _photoView.layer.backgroundColor = [[UIColor blackColor] CGColor];
    _photoView.layer.opacity = 0.9;
    [_bubbleView addSubview:_photoView];
    
    // Bubble Labels
    [_bubbleView addSubview:_nameLabel];
    [_bubbleView addSubview:_messageLabel];
    [_bubbleView addSubview:_timestampLabel];
    
    [self.contentView addSubview:_bubbleView];
    
    // Activity View
    _activityView = [[UIView alloc] initWithFrame:CGRectMake(_psFrameView.right + MARGIN_X, _bubbleView.bottom + MARGIN_Y, _bubbleView.width - MARGIN_X, ACTIVITY_HEIGHT)];
    
    _activityView.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
    _activityView.layer.cornerRadius = 4.0;
    _activityView.layer.masksToBounds = YES;
    _activityView.layer.borderWidth = 1.0;
    _activityView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    // Activity Label
    _activityLabel = [[UILabel alloc] init];
    _activityLabel.font = ACTIVITY_FONT;
    
    _activityLabel.left = MARGIN_X;
    _activityLabel.top = 0.0;
    _activityLabel.width = _activityView.width - MARGIN_X * 2;
    _activityLabel.height = _activityView.height;
    _activityLabel.backgroundColor = [UIColor clearColor];
    [_activityView addSubview:_activityLabel];
    
    [self.contentView addSubview:_activityView];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _messageLabel.text = nil;
  _timestampLabel.text = nil;
  _activityLabel.text = nil;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = _photoView.left + MARGIN_X;
  CGFloat textWidth = _photoView.width - MARGIN_X * 2;

  // Name
  [_nameLabel sizeToFitFixedWidth:textWidth withLineBreakMode:UILineBreakModeTailTruncation withNumberOfLines:1];
  _nameLabel.top = top + MARGIN_Y;
  _nameLabel.left = left;
  
  // Message
  [_messageLabel sizeToFitFixedWidth:textWidth withLineBreakMode:UILineBreakModeTailTruncation withNumberOfLines:1];
  _messageLabel.top = _bubbleView.bottom - _messageLabel.height - MARGIN_Y * 3;
  _messageLabel.left = left;
  
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
//  Album *album = (Album *)object;
  return 120.0;
}

- (void)fillCellWithObject:(id)object {
  Album *album = (Album *)object;
  
  // Author Pic
  _psImageView.urlPath = album.userPictureUrl;
  
  // Photo
  _photoView.urlPath = album.photoUrl;
  
  // Bubble Labels
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
  RELEASE_SAFELY(_photoView);
  
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_messageLabel);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_activityView);
  RELEASE_SAFELY(_activityLabel);
  [super dealloc];
}

@end

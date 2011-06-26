//
//  HeaderCell.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeaderCell.h"
#import "PSURLCacheImageView.h"
#import "Message.h"

#define MARGIN_X 10.0
#define MARGIN_Y 5.0
#define PICTURE_SIZE 20.0

#define NAME_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]
#define SMALL_ITALIC_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0]

static UIImage *_bgImage = nil;

@implementation HeaderCell

+ (void)initialize {
  _bgImage = [[UIImage imageNamed:@"bg-table-header.png"] retain];
}

- (id)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = CELL_BACKGROUND_COLOR;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowOffset = CGSizeMake(0.0, 3.0);
    self.layer.shadowOpacity = 0.25;
    
    _userNameLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    
    _userNameLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    
    _userNameLabel.font = TITLE_FONT;
    _userNameLabel.textColor = [UIColor blackColor];
    
    _timestampLabel.font = TIMESTAMP_FONT;
    _timestampLabel.textColor = [UIColor blackColor];
    
    _timestampLabel.textAlignment = UITextAlignmentRight;
    
    // Profile Picture
    _profilePicture = [[PSURLCacheImageView alloc] initWithFrame:CGRectZero];
    
    [self addSubview:_profilePicture];
    [self addSubview:_userNameLabel];
    [self addSubview:_timestampLabel];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  // Profile Picture
  _profilePicture.frame = CGRectMake(MARGIN_X, MARGIN_Y, PICTURE_SIZE, PICTURE_SIZE);
  
  CGFloat top = 0;
  CGFloat left = _profilePicture.right + MARGIN_X;
  CGFloat textWidth = self.width - left - MARGIN_X;
  CGSize desiredSize = CGSizeZero;
  
  desiredSize = [UILabel sizeForText:_timestampLabel.text width:textWidth font:_timestampLabel.font numberOfLines:1 lineBreakMode:_timestampLabel.lineBreakMode];
  _timestampLabel.width = desiredSize.width;
  _timestampLabel.height = self.height;
  _timestampLabel.top = top;
  _timestampLabel.left = self.width - _timestampLabel.width - MARGIN_X;
  
  desiredSize = [UILabel sizeForText:_userNameLabel.text width:(textWidth - _timestampLabel.width - MARGIN_X) font:_userNameLabel.font numberOfLines:1 lineBreakMode:_userNameLabel.lineBreakMode];
  _userNameLabel.width = desiredSize.width;
  _userNameLabel.height = self.height;
  _userNameLabel.top = top;
  _userNameLabel.left = left;
}

+ (CGFloat)headerHeight {
  return 30.0;
}

- (void)fillCellWithObject:(id)object {
  Message *message = (Message *)object;
  
  _userNameLabel.text = message.fromName;
  _timestampLabel.text = [NSDate stringForDisplayFromDate:message.timestamp];
  
  _profilePicture.urlPath = message.fromPictureUrl;
  [_profilePicture loadImageAndDownload:YES];
}

- (void)dealloc {
  RELEASE_SAFELY(_profilePicture);
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_userNameLabel);
  [super dealloc];
}

@end

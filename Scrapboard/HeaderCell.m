//
//  HeaderCell.m
//  Scrapboard
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeaderCell.h"
#define MARGIN_X 6.0
#define MARGIN_Y 6.0

static UIImage *_bgImage = nil;

@implementation HeaderCell

+ (void)initialize {
  _bgImage = [[UIImage imageNamed:@"row_gradient.png"] retain];
}

- (id)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if (self) {
    self.backgroundColor = [UIColor colorWithPatternImage:_bgImage];
    
    _psImageView = [[PSImageView alloc] initWithFrame:CGRectMake(6, 6, 32, 32)];
    
    _userNameLabel = [[UILabel alloc] init];
    _userNameLabel.backgroundColor = [UIColor clearColor];
    
    _timestampLabel = [[UILabel alloc] init];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.textAlignment = UITextAlignmentRight;
    
    [self addSubview:_psImageView];
    [self addSubview:_userNameLabel];
    [self addSubview:_timestampLabel];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X + _psImageView.width + MARGIN_X;
  CGFloat textWidth = self.width - left - MARGIN_X;
  
  [_userNameLabel sizeToFitFixedWidth:textWidth];
  _userNameLabel.height = 32;
  _userNameLabel.left = left;
  _userNameLabel.top = top;
  
  textWidth -= _userNameLabel.width - MARGIN_X;
  [_timestampLabel sizeToFitFixedWidth:textWidth];
  _timestampLabel.height = 32;
  _timestampLabel.left = self.width - MARGIN_X - _timestampLabel.width;
  _timestampLabel.top = top;
}

- (void)fillCellWithObject:(id)object {
  _psImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", @"CharlieSheen"];
  _userNameLabel.text = @"Charlie Sheen";
  _timestampLabel.text = @"3h";
}

- (void)loadImage {
  [_psImageView loadImage];
}

- (void)dealloc {
  RELEASE_SAFELY(_timestampLabel);
  RELEASE_SAFELY(_userNameLabel);
  RELEASE_SAFELY(_psImageView);
  [super dealloc];
}

@end

//
//  PSImageCell.m
//  Kupo
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSImageCell.h"

static UIImage *_frameImage = nil;

@implementation PSImageCell

+ (void)initialize {
  _frameImage = [[[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    _psImageView = [[PSImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 40)];
    _psFrameView = [[UIImageView alloc] initWithImage:_frameImage];
    _psFrameView.frame = CGRectMake(5, 0, 60, 60);
    
    [self.contentView addSubview:_psFrameView];
    [self.contentView addSubview:_psImageView];
    
    // Override default text labels
    self.textLabel.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [_psImageView unloadImage];
}

- (void)loadImage {
  [_psImageView loadImage];
}

+ (CGFloat)rowHeight {
  // Subclasses should override
  return 60.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)dealloc {
  RELEASE_SAFELY(_psImageView);
  RELEASE_SAFELY(_psFrameView);
  [super dealloc];
}

@end

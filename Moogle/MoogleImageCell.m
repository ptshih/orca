//
//  MoogleImageCell.m
//  Moogle
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleImageCell.h"

static UIImage *_frameImage = nil;

@implementation MoogleImageCell

+ (void)initialize {
  _frameImage = [[[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _moogleImageView = [[MoogleImageView alloc] init];
    _moogleImageView.frame = CGRectMake(10, 10, 40, 40);
    _moogleFrameView = [[UIImageView alloc] initWithImage:_frameImage];
    _moogleFrameView.frame = CGRectMake(0, 0, 60, 60);
    
    [self addSubview:_moogleFrameView];
    [self addSubview:_moogleImageView];
    
    // Override default text labels
    self.textLabel.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [_moogleImageView unloadImage];
}

- (void)loadImage {
  [_moogleImageView loadImage];
}

+ (CGFloat)rowHeight {
  // Subclasses should override
  return 60.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)dealloc {
  RELEASE_SAFELY(_moogleImageView);
  RELEASE_SAFELY(_moogleFrameView);
  [super dealloc];
}

@end

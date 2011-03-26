//
//  MoogleImageCell.m
//  Moogle
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleImageCell.h"

static UIImage *_photoFrame = nil;

@implementation MoogleImageCell

+ (void)initialize {
  _photoFrame = [[[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] retain];  
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _moogleImageView = [[MoogleImageView alloc] init];
    _imageLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_imageLoadingIndicator startAnimating];
    _photoFrameView = [[UIImageView alloc] initWithImage:_photoFrame];
    
    [self.contentView addSubview:_photoFrameView];
    [self.contentView addSubview:_imageLoadingIndicator];
    [self.contentView addSubview:_moogleImageView];
    
    // Override default text labels
    self.textLabel.backgroundColor = [UIColor clearColor];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  if ([[self class] cellType] == MoogleCellTypePlain) {
    _photoFrameView.width = IMAGE_WIDTH_PLAIN + SPACING_X * 2;
    _photoFrameView.height = IMAGE_HEIGHT_PLAIN + SPACING_Y * 2;
    _moogleImageView.width = IMAGE_WIDTH_PLAIN;
    _moogleImageView.height = IMAGE_HEIGHT_PLAIN;
  } else {
    _photoFrameView.width = IMAGE_WIDTH_GROUPED + SPACING_X * 2;
    _photoFrameView.height = IMAGE_HEIGHT_GROUPED + SPACING_Y * 2;
    _moogleImageView.width = IMAGE_WIDTH_GROUPED;
    _moogleImageView.height = IMAGE_HEIGHT_GROUPED;
  }
  _photoFrameView.top = 0;
  _photoFrameView.left = 0;
  _moogleImageView.top = SPACING_Y;
  _moogleImageView.left = SPACING_X;
  
//  _moogleImageView.layer.masksToBounds = YES;
//  _moogleImageView.layer.cornerRadius = 4.0;
  
  _imageLoadingIndicator.frame = CGRectMake(25, 25, 20, 20);

  self.textLabel.left = _moogleImageView.right + SPACING_X;
  
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
  RELEASE_SAFELY(_imageLoadingIndicator);
  RELEASE_SAFELY(_photoFrameView);
  [super dealloc];
}

@end

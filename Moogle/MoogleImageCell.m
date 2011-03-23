//
//  MoogleImageCell.m
//  Moogle
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleImageCell.h"

@implementation MoogleImageCell

@synthesize moogleImageView = _moogleImageView;
@synthesize imageLoadingIndicator = _imageLoadingIndicator;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _moogleImageView = [[MoogleImageView alloc] init];
    _imageLoadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [_imageLoadingIndicator startAnimating];
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
    self.moogleImageView.width = IMAGE_WIDTH_PLAIN;
    self.moogleImageView.height = IMAGE_HEIGHT_PLAIN;
  } else {
    self.moogleImageView.width = IMAGE_WIDTH_GROUPED;
    self.moogleImageView.height = IMAGE_HEIGHT_GROUPED;
  }
  self.moogleImageView.top = SPACING_Y;
  self.moogleImageView.left = SPACING_X;
  self.moogleImageView.layer.masksToBounds = YES;
  self.moogleImageView.layer.cornerRadius = 4.0;
  
  _imageLoadingIndicator.frame = CGRectMake(15, 15, 20, 20);

  self.textLabel.left = self.moogleImageView.right + SPACING_X;
  
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
  [super dealloc];
}

@end

//
//  PhotoCell.m
//  Orca
//
//  Created by Peter Shih on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoCell.h"


@implementation PhotoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Photo
    _photoView = [[PSURLCacheImageView alloc] initWithFrame:CGRectZero];
    _photoView.layer.cornerRadius = 5.0;
    _photoView.layer.masksToBounds = YES;
    _photoView.layer.borderColor = [SEPARATOR_COLOR CGColor];
    _photoView.layer.borderWidth = 1.0;
    [self.contentView addSubview:_photoView];

    // Photo loaded notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhotoFromNotification:) name:kMessageCellReloadPhoto object:nil];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  [_photoView unloadImage];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = _messageLabel.bottom;
  CGFloat left = _quoteView.right + 4.0 + MARGIN_X;
  
  // Photo
    top += 5;
  _photoView.top = top;
  _photoView.left = left;
  _photoView.height = floor([[[_message meta] objectForKey:@"photoHeight"] floatValue] / ([[[_message meta] objectForKey:@"photoWidth"] floatValue] / 270));
  _photoView.width = 270;
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  Message *message = (Message *)object;
  
  CGSize desiredSize = CGSizeZero;
  CGFloat textWidth = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - MARGIN_X * 2 - 16 - 4 - MARGIN_X; // minus quote
  
  CGFloat desiredHeight = 0;
  
  // Top margin
  desiredHeight += MARGIN_Y;
  
  // Message
  desiredSize = [UILabel sizeForText:[[message meta] objectForKey:@"message"] width:textWidth font:NORMAL_FONT numberOfLines:0 lineBreakMode:UILineBreakModeWordWrap];
  desiredHeight += desiredSize.height;
  
  // Optional Photo
  if ([[message meta] objectForKey:@"photoUrl"] && [[[message meta] objectForKey:@"photoWidth"] floatValue] > 0 && [[[message meta] objectForKey:@"photoHeight"] floatValue] > 0) {
    desiredHeight += 5;
    desiredHeight += floor([[[message meta] objectForKey:@"photoHeight"] floatValue] / ([[[message meta] objectForKey:@"photoWidth"] floatValue] / 270));
    desiredHeight += 5;
  }
  
  // Bottom margin
  desiredHeight += MARGIN_Y;
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  [super fillCellWithObject:object];
  
  Message *message = (Message *)object;
  
  // Photo
  _photoView.urlPath = [[message meta] objectForKey:@"photoUrl"];
  [_photoView loadImageAndDownload:NO];
}

- (void)loadPhoto {
  if (_photoView.urlPath) {
    [_photoView loadImageAndDownload:YES];
  }
}

- (void)loadPhotoFromNotification:(NSNotification *)notification {
  NSString *sequence = [[notification userInfo] objectForKey:@"sequence"];
  if (sequence && [sequence isEqualToString:_message.sequence]) {
    [self loadPhoto];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kMessageCellReloadPhoto object:nil];
  RELEASE_SAFELY(_photoView);
  [super dealloc];
}

@end

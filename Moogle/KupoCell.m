//
//  KupoCell.m
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 12.0
#define COMMENT_FONT_SIZE 16.0
#define TIMESTAMP_FONT_SIZE 12.0
#define PHOTO_SIZE 100.0
#define PHOTO_SPACING 5.0

static UIImage *_quoteImage = nil;

@implementation KupoCell

+ (void)initialize {
  _quoteImage = [[UIImage imageNamed:@"quote_mark.png"] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _hasPhoto = NO;
    
    _photoImageView = [[MoogleImageView alloc] init];
    [self.contentView addSubview:_photoImageView];
  }
  return self;
}

// Optimized cell rendering
- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  
  [self drawContentView:rect];
}

- (void)drawContentView:(CGRect)r {
  [super drawContentView:r];
  
  CGFloat top = MARGIN_Y;
  CGFloat left =  MARGIN_X;
  CGFloat width = self.bounds.size.width - left - MARGIN_X;
  CGRect contentRect = CGRectMake(left, top, width, r.size.height);
  CGSize drawnSize = CGSizeZero;
  
  left = _moogleFrameView.right;
  width = self.bounds.size.width - left - MARGIN_X;
  contentRect = CGRectMake(left, top, width, r.size.height);
  
  [[UIColor blackColor] set];
  
  if ([[_kupo.timestamp humanIntervalSinceNow] length] > 0) {
    drawnSize = [[_kupo.timestamp humanIntervalSinceNow] drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
    
    contentRect = CGRectMake(left, top, width - drawnSize.width - MARGIN_X, r.size.height);
  }
  
  if ([_kupo.authorName length] > 0) {
    drawnSize = [_kupo.authorName drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    top += drawnSize.height;
    contentRect.origin.y = top;
  }
  
  contentRect = CGRectMake(left, top, width, r.size.height);
  
  NSString *status = nil;
  if ([_kupo.kupoType integerValue] == 0) {
    if (_kupo.tagged) {
      status = [NSString stringWithFormat:@"Checked in via Facebook with %@", _kupo.tagged];
    } else {
      status = [NSString stringWithFormat:@"Checked in via Facebook"];
    }
  }
  
  if ([status length] > 0) {
    drawnSize = [status drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    top += drawnSize.height;
    contentRect.origin.y = top;
  }
  
  if ([_kupo.comment length] > 0) {
    drawnSize = [_kupo.comment drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:COMMENT_FONT_SIZE] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    top += drawnSize.height;
    contentRect.origin.y = top;
  }
  
//  if (_hasPhoto) {
//    _photoImageView.left = left;
//    _photoImageView.top = top + PHOTO_SPACING;
//    _photoImageView.width = PHOTO_SIZE;
//    _photoImageView.height = PHOTO_SIZE;
//    _photoImageView.layer.masksToBounds = YES;
//    _photoImageView.layer.cornerRadius = 4.0;
//  }
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _hasPhoto = NO;
  [_photoImageView unloadImage];
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object {
  Kupo *kupo = (Kupo *)object;
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X + 60; // image + unread dot
  CGFloat width = [[self class] rowWidth] - left - MARGIN_X;
  CGSize constrainedSize = CGSizeZero;
  CGSize size = CGSizeZero;
  
  CGFloat desiredHeight = top;
  
  constrainedSize = CGSizeMake(width, 300);
  
  size = [[kupo.timestamp humanIntervalSinceNow] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
  
  constrainedSize = CGSizeMake(width - size.width - MARGIN_X, 300);
  
  size = [kupo.authorName sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
  
  desiredHeight += size.height;
  
  constrainedSize = CGSizeMake(width, 300);
  
  NSString *status = nil;
  if ([kupo.kupoType integerValue] == 0) {
    if (kupo.tagged) {
      status = [NSString stringWithFormat:@"Checked in via Facebook with %@", kupo.tagged];
    } else {
      status = [NSString stringWithFormat:@"Checked in via Facebook"];
    }
  }
  
  size = [status sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
  
  desiredHeight += size.height;
  
  size = [kupo.comment sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
  
  desiredHeight += size.height;
  
  if ([kupo.hasPhoto boolValue]) {
    desiredHeight += 110.0;
  }
  
  desiredHeight += MARGIN_Y;
  
  if (desiredHeight < MARGIN_Y) {
    desiredHeight = 60 + MARGIN_Y;
  }
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Kupo *kupo = (Kupo *)object;
  _kupo = kupo;
  
  _moogleImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", kupo.authorId];
  
  if ([kupo.hasPhoto boolValue]) {
    _hasPhoto = YES;
    _photoImageView.urlPath = [NSString stringWithFormat:@"%@/%@/thumb/image.png", S3_PHOTOS_URL, kupo.id];
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
  } else {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
}

- (void)loadPhoto {
  if (_hasPhoto) {
    [_photoImageView loadImage];
  }
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

- (void)dealloc {
  RELEASE_SAFELY(_photoImageView);
  [super dealloc];
}

@end
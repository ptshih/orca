//
//  PlaceCell.m
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaceCell.h"

#define NAME_FONT_SIZE 14.0
#define CELL_FONT_SIZE 12.0
#define TIMESTAMP_FONT_SIZE 12.0
#define ADDRESS_FONT_SIZE 12.0
#define UNREAD_WIDTH 13.0

static UIImage *_unreadImage = nil;

@implementation PlaceCell

+ (void)initialize {
  _unreadImage = [[UIImage imageNamed:@"unread.png"] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
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
  CGRect contentRect = CGRectMake(left, top, width, INT_MAX);
  CGSize drawnSize = CGSizeZero;
  
  // Image View
  
  // Unread indicator
  if (![_place.isRead boolValue]) {
    [_unreadImage drawAtPoint:CGPointMake(left, floor(self.bounds.size.height / 2) - floor(_unreadImage.size.height / 2))];
  }
  
  _moogleFrameView.left = left + _unreadImage.size.width;
  _moogleImageView.left = left + _unreadImage.size.width + 10;
  
  left = _moogleFrameView.right;
  contentRect.origin.x = left;
  
  [[UIColor blackColor] set];
  
  drawnSize = [_place.name drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
  
  top += drawnSize.height;
  contentRect.origin.y = top;
  
  drawnSize = [_place.address drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:ADDRESS_FONT_SIZE] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
  
  top += drawnSize.height;
  contentRect.origin.y = top;
  
  // Last Activity
  NSString *lastActivity = nil;
  if ([_place.kupoType integerValue] == 0) {
    lastActivity = [NSString stringWithFormat:@"%@ checked in here", _place.authorName];
  } else if ([_place.kupoType integerValue] == 1) {
    if ([_place.hasPhoto boolValue]) {
      if ([_place.hasVideo boolValue]) {
        lastActivity = [NSString stringWithFormat:@"%@ shared a video", _place.authorName];
      } else {
        lastActivity = [NSString stringWithFormat:@"%@ shared a photo", _place.authorName];
      }
    } else {
      lastActivity = [NSString stringWithFormat:@"%@ posted a comment", _place.authorName];
    }
  }
  
  drawnSize = [lastActivity drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
  
  top += drawnSize.height;
  contentRect.origin.y = top;
  
  // Summary
  drawnSize = [[NSString stringWithFormat:@"Friends: %@", _place.friendFirstNames] drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
  
  top += drawnSize.height;
  contentRect.origin.y = top;
  
  // Activity Count
  drawnSize = [[NSString stringWithFormat:@"%@ Kupos", _place.friendFirstNames] drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
  
  top += drawnSize.height;
  contentRect.origin.y = top;
  
  _desiredHeight = top + MARGIN_Y;
  
  if (_desiredHeight < _moogleFrameView.bottom) {
    _desiredHeight = _moogleFrameView.bottom + MARGIN_Y;
  }
  
  NSLog(@"desired height: %f", _desiredHeight);
}
    
- (void)layoutSubviews {
  [super layoutSubviews];

}

- (void)prepareForReuse {
  [super prepareForReuse];
  [_moogleImageView unloadImage];
}

- (void)fillCellWithObject:(id)object {
  Place *place = (Place *)object;
  _place = [place retain];
  
//  _moogleImageView.urlPath = place.pictureUrl;
  _moogleImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", place.authorId];
  
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

- (void)dealloc {
  RELEASE_SAFELY(_place);
  [super dealloc];
}

@end

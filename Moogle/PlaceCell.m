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
#define LAST_ACTIVITY_FONT_SIZE 13.0
#define UNREAD_WIDTH 5.0

@implementation PlaceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _friendIds = [[NSMutableArray alloc] initWithCapacity:6];
    _friendPictureArray = [[NSMutableArray alloc] initWithCapacity:6];
    MoogleImageView *profileImage = nil;
    for (int i=0;i<6;i++) {
      profileImage = [[[MoogleImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)] autorelease];
      [_friendPictureArray addObject:profileImage];
    }
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
  CGFloat left = MARGIN_X + 60;
  CGFloat width = self.bounds.size.width - left - MARGIN_X;
  CGRect contentRect = CGRectMake(left, top, width, INT_MAX);
  CGSize drawnSize = CGSizeZero;
  
  if (self.highlighted) {
    [CELL_VERY_LIGHT_BLUE_COLOR set];
  } else {
    [CELL_GRAY_BLUE_COLOR set];
  }
  
  if ( _place.timestamp && [[_place.timestamp humanIntervalSinceNow] length] > 0) {
    drawnSize = [[_place.timestamp humanIntervalSinceNow] drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentRight];
    
    contentRect = CGRectMake(left, top, width - drawnSize.width - MARGIN_X, INT_MAX);
  }
  
  if (self.highlighted) {
    [CELL_WHITE_COLOR set];
  } else {
    [CELL_BLACK_COLOR set];
  }
  
  if ([_place.name length] > 0) {
    drawnSize = [_place.name drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE] lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    
    top += drawnSize.height;
    contentRect.origin.y = top;
  }
  
  contentRect = CGRectMake(left, top, width, INT_MAX);
  
  if (self.highlighted) {
    [CELL_LIGHT_GRAY_COLOR set];
  } else {
    [CELL_GRAY_COLOR set];
  }
  
  if ([_place.address length] > 0) {
    drawnSize = [_place.address drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:ADDRESS_FONT_SIZE] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
    top += drawnSize.height;
    contentRect.origin.y = top;
  }

  if (self.highlighted) {
    [CELL_VERY_LIGHT_BLUE_COLOR set];
  } else {
    [CELL_GRAY_BLUE_COLOR set];
  }
  
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
  
  if (lastActivity && [lastActivity length] > 0) {
    drawnSize = [lastActivity drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LAST_ACTIVITY_FONT_SIZE] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
    top += drawnSize.height;
    contentRect.origin.y = top;
  }
  
  // Friend activity pictures
  if ([_friendIds count] > 0) {
    int i = 0;
    for (MoogleImageView *picture in _friendPictureArray) {
      [picture loadImage];
      picture.top = top;
      picture.left = left + i * picture.width + i * MARGIN_X;
      [self.contentView addSubview:picture];
      i++;
    }
    
    top += 30;
    contentRect.origin.y = top;
  }
  
  if (self.highlighted) {
    [CELL_LIGHT_GRAY_COLOR set];
  } else {
    [CELL_BLUE_COLOR set];
  }
  
  // Activity Count
  NSString *activity = ([_place.activityCount integerValue] > 1) ? [NSString stringWithFormat:@"%@ Kupos from %@", _place.activityCount, _place.friendFirstNames] : [NSString stringWithFormat:@"%@ Kupo from %@", _place.activityCount, _place.friendFirstNames];
  if ([activity length] > 0) {
    drawnSize = [activity drawInRect:contentRect withFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentLeft];
    
    top += drawnSize.height;
    contentRect.origin.y = top;
  }
  
  top += MARGIN_Y;
  
  if (top < 60) {
    top = 60;
  }
  
  // Unread indicator
  if (![_place.isRead boolValue]) {
    [CELL_UNREAD_COLOR set];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, 4, top));
  } else {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect(context, CGRectMake(0, 0, 4, top));
  }
  
//  NSLog(@"place for cell height: %@", _place);
}
    
- (void)layoutSubviews {
  [super layoutSubviews];

}

- (void)prepareForReuse {
  [super prepareForReuse];
  [_moogleImageView unloadImage];
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object {
  Place *place = (Place *)object;
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X + 60; // image
  CGFloat width = [[self class] rowWidth] - left - MARGIN_X;
  CGSize constrainedSize = CGSizeMake(width, INT_MAX);
  CGSize size = CGSizeZero;
  
  CGFloat desiredHeight = top;
  
  size = [[place.timestamp humanIntervalSinceNow] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:TIMESTAMP_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
  
  constrainedSize = CGSizeMake(width - size.width - MARGIN_X, INT_MAX);
  
  size = [place.name sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:NAME_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeWordWrap];
  
  desiredHeight += size.height;
  
  constrainedSize = CGSizeMake(width, INT_MAX);
  
  if ([place.address length] > 0) {
    size = [place.address sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Italic" size:ADDRESS_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
    
    desiredHeight += size.height;
  }
  
  // Last Activity
  NSString *lastActivity = nil;
  if ([place.kupoType integerValue] == 0) {
    lastActivity = [NSString stringWithFormat:@"%@ checked in here", place.authorName];
  } else if ([place.kupoType integerValue] == 1) {
    if ([place.hasPhoto boolValue]) {
      if ([place.hasVideo boolValue]) {
        lastActivity = [NSString stringWithFormat:@"%@ shared a video", place.authorName];
      } else {
        lastActivity = [NSString stringWithFormat:@"%@ shared a photo", place.authorName];
      }
    } else {
      lastActivity = [NSString stringWithFormat:@"%@ posted a comment", place.authorName];
    }
  }
  
  if (lastActivity && [lastActivity length] > 0) {
    size = [lastActivity sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:LAST_ACTIVITY_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
    
    desiredHeight += size.height;
  }
  
  if (place.friendIds && [[place.friendIds componentsSeparatedByString:@","] count] > 1) {
    desiredHeight += 30;
  }
  
  NSString *activity = ([place.activityCount integerValue] > 1) ? [NSString stringWithFormat:@"%@ Kupos from %@", place.activityCount, place.friendFirstNames] : [NSString stringWithFormat:@"%@ Kupo from %@", place.activityCount, place.friendFirstNames];
  
  size = [activity sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:CELL_FONT_SIZE] constrainedToSize:constrainedSize lineBreakMode:UILineBreakModeTailTruncation];
  
  desiredHeight += size.height;
  
  desiredHeight += MARGIN_Y;
  
  // If cell is shorter than image, set min height
  if (desiredHeight < 60) {
    desiredHeight = 60;
  }

  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Place *place = (Place *)object;
  if (_place) RELEASE_SAFELY(_place);
  _place = [place retain];
  
//  _moogleImageView.urlPath = place.pictureUrl;
  _moogleImageView.urlPath = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", place.authorId];
  
  // Activity Friends Photos
  [_friendIds removeAllObjects];
  [_friendIds addObjectsFromArray:[place.friendIds componentsSeparatedByString:@","]];
  [_friendIds removeObject:place.authorId];
  
  
  int i = 0;
  for (MoogleImageView *picture in _friendPictureArray) {
    if (i < [_friendIds count]) {
      [picture setUrlPath:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", [_friendIds objectAtIndex:i]]];
    } else {
      [picture unloadImage];
    }
    i++;
  }
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

- (void)dealloc {
  RELEASE_SAFELY(_friendIds);
  RELEASE_SAFELY(_friendPictureArray);
  RELEASE_SAFELY(_place);
  [super dealloc];
}

@end

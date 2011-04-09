//
//  MoogleCell.m
//  Moogle
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleCell.h"

@interface MoogleCellView : UIView
@end

@implementation MoogleCellView

- (void)drawRect:(CGRect)r {
	[(MoogleCell *)[self superview] drawContentView:r];
}

@end


@implementation MoogleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _separatorStyle = style;
    self.opaque = YES;
    self.contentMode = UIViewContentModeRedraw;
    _moogleContentView = [[MoogleCellView alloc] initWithFrame:CGRectZero];
    _moogleContentView.contentMode = UIViewContentModeRedraw;
    _moogleContentView.opaque = NO;
    [self addSubview:_moogleContentView];
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  [super drawRect:rect];
  [self drawContentView:rect];
}


- (void)drawContentView:(CGRect)r {
  // subclass should implement
}

- (void)setFrame:(CGRect)f {
	[super setFrame:f];
	CGRect b = [self bounds];
  if (_separatorStyle != UITableViewCellSeparatorStyleNone) {
    b.size.height -= 1; // leave room for the seperator line
  }
	[_moogleContentView setFrame:b];
}

- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[_moogleContentView setNeedsDisplay];
}

- (void)setNeedsLayout {
  [super setNeedsLayout];
  [_moogleContentView setNeedsLayout];
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

+ (CGFloat)rowWidth {
  switch ([[self class] cellType]) {
    case MoogleCellTypePlain:
      if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        return 320.0;
      } else {
        return 480.0;
      }
      break;
    case MoogleCellTypeGrouped:
      if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        return 300.0;
      } else {
        return 460.0;
      }
      break;
    default:
      if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        return 320.0;
      } else {
        return 480.0;
      }
      break;
  }
}

+ (CGFloat)rowHeight {
  return 44.0;
}

// This is a class method because it is called before the cell has finished its layout
+ (CGFloat)rowHeightForObject:(id)object {
  // subclass must override
  return 0.0;
}

- (void)fillCellWithObject:(id)object {
  // Subclasses must override
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

//- (void)setHighlighted:(BOOL)lit {
//	// If highlighted state changes, need to redisplay.
//  [self setNeedsDisplay];
//}

- (void)dealloc {
  RELEASE_SAFELY(_moogleContentView);
  [super dealloc];
}

@end

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

@synthesize desiredHeight = _desiredHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    if ([[self class] cellType] == MoogleCellTypePlain) {
      self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"table-cell-bg.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:30]] autorelease];
      self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"table-cell-bg-selected.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:30]] autorelease];
      
      _moogleContentView = [[MoogleCellView alloc] initWithFrame:CGRectZero];
      _moogleContentView.opaque = NO;
      [self addSubview:_moogleContentView];
      [_moogleContentView release];
    }
    _desiredHeight = 0.0;
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
	b.size.height -= 1; // leave room for the seperator line
	[_moogleContentView setFrame:b];
}

- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[_moogleContentView setNeedsDisplay];
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

+ (CGFloat)rowWidth {
  switch ([[self class] cellType]) {
    case MoogleCellTypePlain:
      return 320.0;
      break;
    case MoogleCellTypeGrouped:
      return 300.0;
      break;
    default:
      return 320.0;
      break;
  }
}

+ (CGFloat)rowHeight {
  return 44.0;
}

// This is a class method because it is called before the cell has finished its layout
+ (CGFloat)rowHeightForObject:(id)object {
  static id heightCell = nil;
  if (!heightCell) {
    heightCell = [[[self class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@_HeightCell", [self class]]];
  } else {
    if ([heightCell isMemberOfClass:[self class]]) {
      [heightCell prepareForReuse];
    } else {
      [heightCell release], heightCell = nil;
      heightCell = [[[self class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@_HeightCell", [self class]]];
    }
  }
  
  if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
    [heightCell setWidth:320];
  } else {
    [heightCell setWidth:480];
  }
  

  [heightCell fillCellWithObject:object];
  NSLog(@"height cell: %f", [(MoogleCell *)heightCell desiredHeight]);  
  return [(MoogleCell *)heightCell desiredHeight];
}

- (void)fillCellWithObject:(id)object {
  // Subclasses must override
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)lit {
	// If highlighted state changes, need to redisplay.
  [self setNeedsDisplay];
}

- (void)dealloc {
  [super dealloc];
}

@end

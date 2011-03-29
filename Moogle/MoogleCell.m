//
//  MoogleCell.m
//  Moogle
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleCell.h"


@implementation MoogleCell

@synthesize desiredHeight = _desiredHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    if ([[self class] cellType] == MoogleCellTypePlain) {
      self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"table-cell-bg.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:30]] autorelease];
      self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"table-cell-bg-selected.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:30]] autorelease];
    }
    _desiredHeight = 0.0;
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _desiredHeight = 0.0;
}

- (void)layoutSubviews {
  [super layoutSubviews];
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
    if ([heightCell isMemberOfClass:[object class]]) {
      [heightCell prepareForReuse];
    } else {
      [heightCell release], heightCell = nil;
      heightCell = [[[self class] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[NSString stringWithFormat:@"%@_HeightCell", [self class]]];
    }
  }
  
  [heightCell fillCellWithObject:object];
  [heightCell layoutSubviews];
  
  return [(MoogleCell *)heightCell desiredHeight];
}

- (void)fillCellWithObject:(id)object {
  // Subclasses must override
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)dealloc {
  [super dealloc];
}

@end

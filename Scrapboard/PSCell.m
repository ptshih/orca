//
//  PSCell.m
//  Scrapboard
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCell.h"

@implementation PSCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _separatorStyle = style;
    self.opaque = YES;
    self.contentMode = UIViewContentModeRedraw;
  }
  return self;
}

+ (PSCellType)cellType {
  return PSCellTypePlain;
}

+ (CGFloat)rowWidth {
  switch ([[self class] cellType]) {
    case PSCellTypePlain:
      if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        return 320.0;
      } else {
        return 480.0;
      }
      break;
    case PSCellTypeGrouped:
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

- (void)dealloc {
  [super dealloc];
}

@end

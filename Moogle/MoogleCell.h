//
//  MoogleCell.h
//  Moogle
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "NetworkConstants.h"

#define MARGIN_X 10.0
#define MARGIN_Y 5.0

enum {
  MoogleCellTypePlain = 0,
  MoogleCellTypeGrouped = 1
};
typedef uint32_t MoogleCellType;


@interface MoogleCell : UITableViewCell {
  UIView *_moogleContentView;
  UITableViewCellSeparatorStyle _separatorStyle;
}

- (void)drawContentView:(CGRect)r;

+ (MoogleCellType)cellType;
+ (CGFloat)rowWidth;

/**
 Used for static height cells
 Subclasses should implement or else defaults to 44.0
 */
+ (CGFloat)rowHeight;

/**
 Used for variable height cells
 Attempts to call layoutSubviews for the corresponding cell class
 With the object passed
 */
+ (CGFloat)rowHeightForObject:(id)object;

- (void)fillCellWithObject:(id)object;

@end

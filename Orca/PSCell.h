//
//  PSCell.h
//  Orca
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "NetworkConstants.h"
#import "PSImageView.h"

#define MARGIN_X 5.0
#define MARGIN_Y 5.0

enum {
  PSCellTypePlain = 0,
  PSCellTypeGrouped = 1
};
typedef uint32_t PSCellType;


@interface PSCell : UITableViewCell {
  UITableViewCellSeparatorStyle _separatorStyle;
}

/**
 Reusable Cell Identifier
 Subclasses do NOT need to implement this unless custom behavior is needed
 */
+ (NSString *)reuseIdentifier;

+ (PSCellType)cellType;
+ (CGFloat)rowWidthForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

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
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)fillCellWithObject:(id)object;
- (void)fillCellWithObject:(id)object shouldLoadImages:(BOOL)shouldLoadImages;

@end

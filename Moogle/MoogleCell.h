//
//  MoogleCell.h
//  Moogle
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

enum {
  MoogleCellTypePlain = 0,
  MoogleCellTypeGrouped = 1
};
typedef uint32_t MoogleCellType;


@interface MoogleCell : UITableViewCell {
}

+ (MoogleCellType)cellType;
+ (CGFloat)rowHeight;
+ (CGFloat)variableRowHeightWithDictionary:(NSDictionary *)dictionary;
+ (CGFloat)variableRowHeightWithText:(NSString *)text andFontSize:(CGFloat)fontSize;

@end

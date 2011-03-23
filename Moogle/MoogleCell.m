//
//  MoogleCell.m
//  Moogle
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleCell.h"


@implementation MoogleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    if ([[self class] cellType] == MoogleCellTypePlain) {
      self.backgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"table-cell-bg.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:30]] autorelease];
      self.selectedBackgroundView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"table-cell-bg-selected.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:30]] autorelease];
    }
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)layoutSubviews {
  [super layoutSubviews];
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

+ (CGFloat)rowHeight {
  // Subclasses should override
  return 44.0;
}

+ (CGFloat)variableRowHeightWithDictionary:(NSDictionary *)dictionary {
  return 0.0;
}

+ (CGFloat)variableRowHeightWithText:(NSString *)text andFontSize:(CGFloat)fontSize {
  CGFloat calculatedHeight = 0.0;
  
  CGFloat left = 10;
  CGFloat textWidth = 300;
  CGSize textSize = CGSizeZero;
  CGSize labelSize = CGSizeZero;
  
  // Text
  textWidth = 300 - left - 10;
  textSize = CGSizeMake(textWidth, INT_MAX);
  
  labelSize = [text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:textSize lineBreakMode:UILineBreakModeWordWrap];
  
  calculatedHeight = calculatedHeight + labelSize.height;
  
  calculatedHeight = calculatedHeight + 10 * 2; // This is spacing*2 because its for top AND bottom
  
  return calculatedHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  [super setSelected:selected animated:animated];
}

- (void)dealloc {
  [super dealloc];
}

@end

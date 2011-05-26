//
//  UILabel+SizeToFitWidth.m
//  PhotoFeed
//
//  Created by Peter Shih on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UILabel+SizeToFitWidth.h"


@implementation UILabel (SizeToFitWidth)

- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth withLineBreakMode:(UILineBreakMode)lineBreakMode {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
  self.lineBreakMode = lineBreakMode;
  [self sizeToFit];
}

+ (CGSize)sizeForText:(NSString*)text width:(CGFloat)width font:(UIFont*)font numberOfLines:(NSInteger)numberOfLines lineBreakMode:(UILineBreakMode)lineBreakMode {
  
  if (numberOfLines == 0) numberOfLines = INT_MAX;
  
  CGFloat lineHeight = [@"A" sizeWithFont:font].height;
  return [text sizeWithFont:font constrainedToSize:CGSizeMake(width, numberOfLines*lineHeight) lineBreakMode:lineBreakMode];
}

@end

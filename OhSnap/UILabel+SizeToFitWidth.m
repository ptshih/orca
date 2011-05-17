//
//  UILabel+SizeToFitWidth.m
//  OhSnap
//
//  Created by Peter Shih on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UILabel+SizeToFitWidth.h"


@implementation UILabel (SizeToFitWidth)

- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth withLineBreakMode:(UILineBreakMode)lineBreakMode withNumberOfLines:(NSInteger)numberOfLines {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
  self.lineBreakMode = lineBreakMode;
  self.numberOfLines = numberOfLines;
  [self sizeToFit];

  if (numberOfLines > 0) {
    CGRect frame = self.frame;
    frame.size.width = fixedWidth;
    self.frame = frame;
  }
}

@end

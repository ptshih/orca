//
//  UILabel+SizeToFitWidth.m
//  Moogle
//
//  Created by Peter Shih on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UILabel+SizeToFitWidth.h"


@implementation UILabel (SizeToFitWidth)

- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth {
  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
  self.lineBreakMode = UILineBreakModeWordWrap;
  self.numberOfLines = 0;
  [self sizeToFit];
}

@end

//
//  UILabel+SizeToFitWidth.h
//  PhotoFeed
//
//  Created by Peter Shih on 3/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UILabel (SizeToFitWidth)

- (void)sizeToFitFixedWidth:(NSInteger)fixedWidth withLineBreakMode:(UILineBreakMode)lineBreakMode;

+ (CGSize)sizeForText:(NSString*)text width:(CGFloat)width font:(UIFont*)font numberOfLines:(NSInteger)numberOfLines lineBreakMode:(UILineBreakMode)lineBreakMode;

@end
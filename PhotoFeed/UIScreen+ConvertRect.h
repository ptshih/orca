//
//  UIScreen+ConvertRect.h
//  PhotoFeed
//
//  Created by Peter Shih on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIScreen (UIScreen_ConvertRect)

+ (CGRect) convertRect:(CGRect)rect toView:(UIView *)view;

@end

//
//  UIScreen+ConvertRect.m
//  Moogle
//
//  Created by Peter Shih on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIScreen+ConvertRect.h"


@implementation UIScreen (UIScreen_ConvertRect)

+ (CGRect) convertRect:(CGRect)rect toView:(UIView *)view {
  UIWindow *window = [view isKindOfClass:[UIWindow class]] ? (UIWindow *) view : [view window];
  return [view convertRect:[window convertRect:rect fromWindow:nil] fromView:nil];
}

@end

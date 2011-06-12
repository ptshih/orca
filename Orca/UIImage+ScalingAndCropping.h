//
//  UIImage+ScalingAndCropping.h
//  InPad
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (ScalingAndCropping)
- (CGSize)scaledSizeProportionalToSize:(CGSize)desiredSize;
- (CGSize)scaledSizeBoundedByWidth:(CGFloat)desiredWidth;
- (UIImage *)scaleToSize:(CGSize)size;
- (UIImage *)scaleProportionalToSize:(CGSize)desiredSize;
- (UIImage *)cropProportionalToSize:(CGSize)desiredSize;
- (UIImage *)cropProportionalToSize:(CGSize)desiredSize withRuleOfThirds:(BOOL)withRuleOfThirds;
- (UIImage *)scaledProportionalToSize:(CGSize)desiredSize;
- (UIImage *)scaledBoundedByWidth:(CGFloat)desiredWidth;
@end
//
//  UIImage+ScalingAndCropping.m
//  InPad
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import "UIImage+ScalingAndCropping.h"

@implementation UIImage (ScalingAndCropping)

- (CGSize)scaledSizeProportionalToSize:(CGSize)desiredSize {
  if(self.size.width > self.size.height) {
    // Landscape
    desiredSize = CGSizeMake((self.size.width / self.size.height) * desiredSize.height, desiredSize.height);
  } else {
    // Portrait
    desiredSize = CGSizeMake(desiredSize.width, (self.size.height / self.size.width) * desiredSize.width);
  }
  
  return desiredSize;
}

- (CGSize)scaledSizeBoundedByWidth:(CGFloat)desiredWidth {
  CGSize desiredSize;
  if(self.size.width > self.size.height) {
    // Landscape
    desiredSize = CGSizeMake(desiredWidth, (self.size.width / (self.size.width / desiredWidth)));
  } else {
    // Portrait
    desiredSize = CGSizeMake(desiredWidth, (self.size.height / self.size.width) * desiredWidth);
  }
  
  return desiredSize;
}

- (UIImage *)scaleToSize:(CGSize)desiredSize {
  CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
  CGContextRef ctx = CGBitmapContextCreate(NULL, desiredSize.width, desiredSize.height, 8, 0, colorSpaceRef, kCGImageAlphaPremultipliedLast);
  CGContextClearRect(ctx, CGRectMake(0, 0, desiredSize.width, desiredSize.height));
  
  if(self.imageOrientation == UIImageOrientationRight) {
    CGContextRotateCTM(ctx, -M_PI_2);
    CGContextTranslateCTM(ctx, -desiredSize.height, 0.0f);
    CGContextDrawImage(ctx, CGRectMake(0, 0, desiredSize.height, desiredSize.width), self.CGImage);
  } else {
    CGContextDrawImage(ctx, CGRectMake(0, 0, desiredSize.width, desiredSize.height), self.CGImage);
  }
  
  CGImageRef scaledImage = CGBitmapContextCreateImage(ctx);
  
  CGColorSpaceRelease(colorSpaceRef);
  CGContextRelease(ctx);
  
  UIImage *image = [UIImage imageWithCGImage:scaledImage];
  
  CGImageRelease(scaledImage);
  
  return image;
}

/**
 This just scales
 */
- (UIImage *)scaleProportionalToSize:(CGSize)desiredSize {
  if(self.size.width > self.size.height) {
    // Landscape
    desiredSize = CGSizeMake((self.size.width / self.size.height) * desiredSize.height, desiredSize.height);
  } else {
    // Portrait
    desiredSize = CGSizeMake(desiredSize.width, (self.size.height / self.size.width) * desiredSize.width);
  }
  
  return [self scaleToSize:desiredSize];
}

/**
 Crops an image by first scaling the image (if it is smaller than the desired size)
 so that the resulting crop will fully fill to the desired size.
 
 The resulting crop will be in the absolute center of the original image
 
 Example:
 I want an image that will fit into 320x480 but the image I am given is 200x200
 The code will first scale the image to fit the largest dimension of the desired size (480x480 in this case)
 Then it will crop 80 pixels offset from the left and right resulting in an image that is 320x480
 */
- (UIImage *)cropProportionalToSize:(CGSize)desiredSize {
  return [self cropProportionalToSize:desiredSize withRuleOfThirds:NO];
}

- (UIImage *)cropProportionalToSize:(CGSize)desiredSize withRuleOfThirds:(BOOL)withRuleOfThirds {
  CGFloat desiredWidth = desiredSize.width;
  CGFloat desiredHeight = desiredSize.height;
  CGFloat maxDimension = (desiredWidth > desiredHeight) ? desiredWidth : desiredHeight;
  
  if (self.size.width > self.size.height) {
    // Landscape
    self = [self scaleProportionalToSize:CGSizeMake(INT_MAX, maxDimension)];
  } else if (self.size.width < self.size.height) {
    // Portrait
    self = [self scaleProportionalToSize:CGSizeMake(maxDimension, INT_MAX)];
  } else {
    // Square
    self = [self scaleProportionalToSize:CGSizeMake(maxDimension, maxDimension)];
  }
  
  CGFloat leftMargin = ceil((self.size.width - desiredWidth) / 2);
  CGFloat topMargin = 0.0;
  if (withRuleOfThirds) {
    topMargin = ceil((self.size.height / 3) / 2);
  } else {
    topMargin = ceil((self.size.height - desiredHeight) / 2);
  }
  
  CGRect desiredRect = CGRectMake(leftMargin, topMargin, desiredWidth, desiredHeight);
  
  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], desiredRect);
  UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  return croppedImage;
}

- (UIImage *)scaledProportionalToSize:(CGSize)desiredSize {
  CGFloat desiredWidth = desiredSize.width;
  CGFloat desiredHeight = desiredSize.height;
  CGFloat maxDimension = (desiredWidth > desiredHeight) ? desiredWidth : desiredHeight;
  
  if (self.size.width > self.size.height) {
    // Landscape
    self = [self scaleProportionalToSize:CGSizeMake(INT_MAX, maxDimension)];
  } else if (self.size.width < self.size.height) {
    // Portrait
    self = [self scaleProportionalToSize:CGSizeMake(maxDimension, INT_MAX)];
  } else {
    // Square
    self = [self scaleProportionalToSize:CGSizeMake(maxDimension, maxDimension)];
  }
  return self;
}

- (UIImage *)scaledBoundedByWidth:(CGFloat)desiredWidth {
  CGSize desiredSize = [self scaledSizeBoundedByWidth:desiredWidth];
  
  CGRect desiredRect = CGRectMake(0, 0, desiredSize.width, desiredSize.height);

  CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], desiredRect);
  UIImage *scaledImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  return scaledImage; 
  
}

@end
//
//  NSString+URLEncoding+PS.m
//  Seven Minute Apps
//
//  Created by Peter Shih on 2/17/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import "NSString+URLEncoding+PS.h"


@implementation NSString (URLEncodingAdditions_PS)

- (NSString *)encodedURLString {
  NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                         (CFStringRef)self,
                                                                         NULL,              
                                                                         CFSTR("?=&+"),         
                                                                         kCFStringEncodingUTF8);
  return [result autorelease];
}

- (NSString *)encodedURLParameterString {
  NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                         (CFStringRef)self,
                                                                         NULL,
                                                                         CFSTR(":/=,!$&'()*+;[]@#?"),
                                                                         kCFStringEncodingUTF8);
  
  return [result autorelease];
}

@end

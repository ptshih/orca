//
//  NSString+Util.m
//  Friendmash
//
//  Created by Peter Shih on 11/6/10.
//  Copyright 2010 Seven Minute Apps. All rights reserved.
//

#import "NSString+Util.h"


@implementation NSString (Util)

+ (NSString *)uuidString {
  CFUUIDRef theUUID = CFUUIDCreate(NULL);
  CFStringRef string = CFUUIDCreateString(NULL, theUUID);
  CFRelease(theUUID);
  return [(NSString *)string autorelease];
}

- (NSString *)stringWithPercentEscape {            
  return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"),kCFStringEncodingUTF8) autorelease];
}

@end

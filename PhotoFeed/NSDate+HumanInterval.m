//
//  NSDate+HumanInterval.m
//  Talented
//
//  Created by Peter Shih on 12/21/10.
//  Copyright 2010 Seven Minute Apps. All rights reserved.
//

#import "NSDate+HumanInterval.h"

#define SECOND     1
#define MINUTE (  60 * SECOND )
#define HOUR   (  60 * MINUTE )
#define DAY    (  24 * HOUR   )
#define WEEK   (   7 * DAY    )
#define MONTH  (  30 * DAY    )
#define YEAR   ( 365 * DAY    )

@implementation NSDate (HumanInterval)

- (NSString *)humanIntervalSinceNow {
  int delta = [self timeIntervalSinceNow];
  delta *= -1;
  if (delta < 0) {
    return NSLocalizedString(@"just now", nil);
  } else if (delta <= 30 * SECOND) {
    return NSLocalizedString(@"just now", nil);
  } else if (delta < 1 * MINUTE) {
    return [NSString stringWithFormat:@"%u sec", delta];
  } else if (delta < 2 * MINUTE) {
    return @"1 min";
  } else if (delta <= 45 * MINUTE) {
    return [NSString stringWithFormat:@"%u min", delta / MINUTE];
  } else if (delta <= 90 * MINUTE) {
    return @"1 hr";
  } else if (delta < 3 * HOUR) {
    return @"2 hr";
  } else if (delta < 23 * HOUR) {
    return [NSString stringWithFormat:@"%u hr", delta / HOUR];
  } else if (delta < 36 * HOUR) {
    return @"1 day";
  } else if (delta < 72 * HOUR) {
    return @"2 day";
  } else if (delta < 7 * DAY) {
    return [NSString stringWithFormat:@"%u day", delta / DAY];
  } else if (delta < 11 * DAY) {
    return @"1 wk";
  } else if (delta < 14 * DAY) {
    return @"2 wk";
  } else if (delta < 9 * WEEK) {
    return [NSString stringWithFormat:@"%u wk", delta / WEEK];
  } else if (delta < 19 * MONTH) {
    return [NSString stringWithFormat:@"%u mo", delta / MONTH];        
  } else if (delta < 2 * YEAR) {
    return @"1 yr";
  } else {
    return [NSString stringWithFormat:@"%u yr", delta / YEAR];        
  }
}

@end

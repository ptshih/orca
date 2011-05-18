//
//  NSDate+Util.m
//  InTouch
//
//  Created by Nick Gillett on 3.18.10.
//  Copyright 2010 LinkedIn Inc. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Util)

- (double)millisecondsSince1970 {
  NSTimeInterval timeSince1970 = [self timeIntervalSince1970];
  double milliseconds = ceil(timeSince1970 * 1000);
  return milliseconds;
}

+ (NSDate *)dateWithMillisecondsSince1970:(double)millisecondsSince1970 {
  NSTimeInterval secondsSince1970 = millisecondsSince1970 / 1000;
  return [NSDate dateWithTimeIntervalSince1970:secondsSince1970];
}

- (NSString *)formatDateTime {
  static NSDateFormatter *formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setLocale:[NSLocale currentLocale]];
  }
  
  NSString *formattedStr = nil;
  formattedStr = [formatter stringFromDate:self];
  return formattedStr;
}

- (NSString *)formatLongDateTime {
  static NSDateFormatter *formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    
    [formatter setTimeStyle:kCFDateFormatterMediumStyle];
    [formatter setDateStyle:NSDateFormatterLongStyle];
    [formatter setLocale:[NSLocale currentLocale]];
  }
  
  NSString *formattedStr = nil;
  formattedStr = [formatter stringFromDate:self];
  return formattedStr;
}

+ (NSDate *)dateFromDictionary:(NSDictionary *)monthYearDayDict {
  NSDate *date = nil;
  
  if (monthYearDayDict) {
    NSNumber *monthNumber = [monthYearDayDict valueForKey:@"month"];
    NSNumber *yearNumber = [monthYearDayDict valueForKey:@"year"];
    NSNumber *dayNumber = [monthYearDayDict valueForKey:@"day"];
    
    if (monthNumber && yearNumber && dayNumber) {
      NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
      NSDateComponents *components = [[NSDateComponents alloc] init];
      [components setCalendar:calendar];
      [components setYear:[yearNumber intValue]];
      [components setMonth:[monthNumber intValue]];
      [components setDay:[dayNumber intValue]];
      
      date = [calendar dateFromComponents:components];
      [components release];
      [calendar release];
    }
  }
  
  return date;
}

+ (NSDate *)dateFromFacebookTimestamp:(NSString *)timestamp {
  NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
  // 2010-12-01T21:35:43+0000  
  [df setDateFormat:@"yyyy-mm-dd'T'HH:mm:ssZZZZ"];
  return [df dateFromString:timestamp];
}

@end

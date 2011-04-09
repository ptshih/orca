//
//  NSDate+Util.h
//  InTouch
//
//  Created by Nick Gillett on 3.18.10.
//  Copyright 2010 LinkedIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDate (Util)

- (double)millisecondsSince1970;

+ (NSDate *)dateWithMillisecondsSince1970:(double)millisecondsSince1970;

- (NSString *)formatDateTime;
- (NSString *)formatLongDateTime;

+ (NSDate *)dateFromDictionary:(NSDictionary *)monthYearDayDict;

@end

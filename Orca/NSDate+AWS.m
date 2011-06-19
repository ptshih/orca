//
//  NSDate+AWS.m
//  Orca
//
//  Created by Peter Shih on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDate+AWS.h"


@implementation NSDate (NSDate_AWS)

- (NSString *)awsRequestFormat {
  NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
  
  [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
  [dateFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
  
  return [dateFormatter stringFromDate:self];
}

@end

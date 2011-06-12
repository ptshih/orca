//
//  NSURL+Util.m
//  Orca
//
//  Created by Peter Shih on 5/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSURL+Util.h"


@implementation NSURL (Util)

- (NSURL *)URLByRemovingQuery {
  NSMutableString *URLString = [NSMutableString stringWithFormat:@"%@://", [self scheme]];
  
  if ([self user] && [self password]) [URLString appendFormat:@"%@:%@@", [self user], [self password]];
  
  if ([self host]) {
    [URLString appendString:[self host]];
  }
  if ([self port]) {
    [URLString appendFormat:@":%d", [[self port] integerValue]];
  }
  if ([self path]) {
    [URLString appendString:[self path]];
  }
//  if (query) {
//    [URLString appendFormat:@"?%@", query];
//  }
//  if ([self fragment]) {
//    [URLString appendFormat:@"#%@", [self fragment]];
//  }
  return [NSURL URLWithString:URLString];
}

@end

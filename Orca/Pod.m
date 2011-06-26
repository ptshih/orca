//
//  Pod.m
//  Orca
//
//  Created by Peter Shih on 6/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Pod.h"
#import "JSON.h"

@implementation Pod
@dynamic id;
@dynamic fromPictureUrl;
@dynamic fromId;
@dynamic timestamp;
@dynamic fromName;
@dynamic participants;
@dynamic sequence;
@dynamic name;
@dynamic unread;
@dynamic metadata;

- (NSDictionary *)meta {
  return [self.metadata JSONValue];
}

@end

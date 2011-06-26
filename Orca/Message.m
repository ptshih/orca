//
//  Message.m
//  Orca
//
//  Created by Peter Shih on 6/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Message.h"
#import "JSON.h"

#define USE_FAKE_LAT_LNG

@implementation Message
@dynamic id;
@dynamic timestamp;
@dynamic fromName;
@dynamic podId;
@dynamic sequence;
@dynamic fromPictureUrl;
@dynamic fromId;
@dynamic messageType;
@dynamic metadata;

- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coordinate;
#ifdef USE_FAKE_LAT_LNG
	coordinate.longitude = -122.4100;
	coordinate.latitude = 37.7805;
#else
	coordinate.longitude = [[self valueForKey:@"lng"] floatValue];
	coordinate.latitude = [[self valueForKey:@"lat"] floatValue];
#endif
	return coordinate;
}

- (NSDictionary *)meta {
  return [self.metadata JSONValue];
}

@end

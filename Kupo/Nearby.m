//
//  Nearby.m
//  Kupo
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Nearby.h"

@implementation Nearby

@synthesize id = _id;
@synthesize name = _name;
@synthesize distance = _distance;
@synthesize lat = _lat;
@synthesize lng = _lng;

- (id)initWithDictionary:(NSDictionary *)dictionary {
  self = [super init];
  if (self) {
    self.id = [dictionary valueForKey:@"place_id"];
    self.name = [dictionary valueForKey:@"place_name"];
    self.distance = [dictionary valueForKey:@"place_distance"];
    self.lat = [dictionary valueForKey:@"place_lat"];
    self.lng = [dictionary valueForKey:@"place_lng"];
  }
  return self;
}

- (CLLocationCoordinate2D)coordinate {
  _coordinate.latitude = [self.lat doubleValue];
  _coordinate.longitude = [self.lng doubleValue];
  return _coordinate;
}

- (void)dealloc {
  RELEASE_SAFELY(_id);
  RELEASE_SAFELY(_name);
  RELEASE_SAFELY(_distance);
  RELEASE_SAFELY(_lat);
  RELEASE_SAFELY(_lng);
  [super dealloc];
}

@end

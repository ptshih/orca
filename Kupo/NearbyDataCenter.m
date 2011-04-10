//
//  NearbyDataCenter.m
//  Kupo
//
//  Created by Peter Shih on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbyDataCenter.h"
#import "KupoLocation.h"
#import "Nearby.h"

static NearbyDataCenter *_defaultCenter = nil;

@implementation NearbyDataCenter

@synthesize nearbyPlaces = _nearbyPlaces;

#pragma mark -
#pragma mark Shared Instance
+ (id)defaultCenter {
  @synchronized(self) {
    if (_defaultCenter == nil) {
      _defaultCenter = [[self alloc] init];
      _defaultCenter.nearbyPlaces = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    }
    return _defaultCenter;
  }
}

- (void)getNearbyPlaces {
  CGFloat lat = [[KupoLocation sharedInstance] latitude];
  CGFloat lng = [[KupoLocation sharedInstance] longitude];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
  [params setObject:[NSString stringWithFormat:@"%f", lng] forKey:@"lng"];
  
  // Set distance to 2 miles
  [params setObject:@"2" forKey:@"distance"];
  
  NSURL *placesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/places/nearby", KUPO_BASE_URL]];
  
  [self sendOperationWithURL:placesUrl andMethod:GET andHeaders:nil andParams:params];
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {
  // Serialize nearby places
  [_nearbyPlaces removeAllObjects];
  NSArray *nearbyArray = [_response valueForKey:@"values"];
  for (NSDictionary *nearbyDict in nearbyArray) {
    Nearby *nearbyPlace = [[[Nearby alloc] initWithDictionary:nearbyDict] autorelease];
    [_nearbyPlaces addObject:nearbyPlace];
  }
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFailedWithOperation:operation];
}

- (void)dealloc {
  RELEASE_SAFELY(_nearbyPlaces);
  [super dealloc];
}

@end

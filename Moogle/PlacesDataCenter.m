//
//  PlacesDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlacesDataCenter.h"
#import "MoogleLocation.h"

@implementation PlacesDataCenter

- (void)getNearbyPlaces {
  CGFloat lat = [[MoogleLocation sharedInstance] latitude];
  CGFloat lng = [[MoogleLocation sharedInstance] longitude];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
  [params setObject:[NSString stringWithFormat:@"%f", lng] forKey:@"lng"];
  
  // Set distance to 2 miles
  [params setObject:@"2" forKey:@"distance"];
  
  NSURL *placesUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/places/nearby", MOOGLE_BASE_URL]];
  
  [self sendOperationWithURL:placesUrl andMethod:GET andHeaders:nil andParams:params];
}

#pragma mark MoogleDataCenterDelegate
- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {  
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFailedWithOperation:operation];
}

@end

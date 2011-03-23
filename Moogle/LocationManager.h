//
//  LocationManager.h
//  Moogle
//
//  Created by Peter Shih on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MoogleObject.h"

@interface LocationManager : MoogleObject <CLLocationManagerDelegate> {
  CLLocationManager *_locationManager;
  CLLocation *_oldLocation;
  CLLocation *_currentLocation;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *oldLocation;
@property (nonatomic, retain) CLLocation *currentLocation;

- (void)startStandardUpdates;
- (void)stopStandardUpdates;

- (void)startSignificantChangeUpdates;

- (BOOL)hasAcquiredLocation;

- (CGFloat)latitude;
- (CGFloat)longitude;
- (NSInteger)distance;

@end

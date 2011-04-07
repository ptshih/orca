//
//  MoogleLocation.h
//  Moogle
//
//  Created by Peter Shih on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "MoogleObject.h"

@interface MoogleLocation : MoogleObject <CLLocationManagerDelegate> {
  CLLocationManager *_locationManager;
  CLLocation *_currentLocation;
  CLLocation *_oldLocation;
}

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *oldLocation;
@property (nonatomic, retain) CLLocation *currentLocation;

+ (MoogleLocation *)sharedInstance;

// Distance Filter
- (void)setDistanceFilter:(NSInteger)distanceFilter;
- (NSInteger)distanceFilter;

// Location Updates
- (void)startStandardUpdates;
- (void)stopStandardUpdates;
- (void)startSignificantChangeUpdates;
- (void)stopSignificantChangeUpdates;

// Location Coordinates
- (BOOL)hasAcquiredLocation;
- (CGFloat)latitude;
- (CGFloat)longitude;

@end

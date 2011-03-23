//
//  LocationManager.m
//  Moogle
//
//  Created by Peter Shih on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LocationManager.h"

static NSInteger _distance = 1000;

@implementation LocationManager

@synthesize locationManager = _locationManager;
@synthesize oldLocation = _oldLocation;
@synthesize currentLocation = _currentLocation;


- (void)startStandardUpdates {
  // Create the location manager if this object does not
  // already have one.
  if (nil == _locationManager)
    _locationManager = [[CLLocationManager alloc] init];
  
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
  
  // Set a movement threshold for new events.
  self.locationManager.distanceFilter = _distance;
  
  [self.locationManager startUpdatingLocation];
}

- (void)stopStandardUpdates {
  [self.locationManager stopUpdatingLocation];
  self.oldLocation = nil;
  self.currentLocation = nil;
}

- (void)startSignificantChangeUpdates {
  // Create the location manager if this object does not
  // already have one.
  if (nil == _locationManager)
    self.locationManager = [[CLLocationManager alloc] init];
  
  self.locationManager.delegate = self;
  [self.locationManager startMonitoringSignificantLocationChanges];
}

- (BOOL)hasAcquiredLocation {
  if (self.currentLocation) return YES;
  else return NO;
}

- (CGFloat)latitude {
  return self.currentLocation.coordinate.latitude;
}

- (CGFloat)longitude {
  return self.currentLocation.coordinate.longitude;
}

- (NSInteger)distance {
  return _distance;
}

#pragma mark CLLocationManagerDelegate
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  // If it's a relatively recent event, turn off updates to save power
  NSDate* eventDate = newLocation.timestamp;
  
  NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
  if (abs(howRecent) < 15.0)
  {
    self.oldLocation = self.currentLocation;
    self.currentLocation = newLocation;
    
    NSLog(@"latitude %+.6f, longitude %+.6f\n",
          newLocation.coordinate.latitude,
          newLocation.coordinate.longitude);

    if (!self.oldLocation) {
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
      }
    }
  }
  // else skip the event and process the next one.
}

- (void)dealloc {
  RELEASE_SAFELY(_locationManager);
  RELEASE_SAFELY(_oldLocation);
  RELEASE_SAFELY(_currentLocation);
  [super dealloc];
}

@end

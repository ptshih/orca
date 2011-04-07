//
//  MoogleLocation.m
//  Moogle
//
//  Created by Peter Shih on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleLocation.h"

static MoogleLocation *_sharedInstance = nil;
static NSInteger _distanceFilter = 1000;

@implementation MoogleLocation

@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;
@synthesize oldLocation = _oldLocation;

#pragma mark Singleton methods
+ (void)initialize {
	@synchronized(self) {
    if (_sharedInstance == nil) {
      _sharedInstance = [[MoogleLocation alloc] init];
      _sharedInstance.locationManager = [[CLLocationManager alloc] init];
      _sharedInstance.locationManager.delegate = _sharedInstance;
      _sharedInstance.locationManager.distanceFilter = _distanceFilter;
      _sharedInstance.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
      
      _sharedInstance.currentLocation = nil;
      _sharedInstance.oldLocation = nil;
		}
  }
}

+ (MoogleLocation *)sharedInstance {
  return _sharedInstance;
}

#pragma mark -
#pragma mark Distance
- (void)setDistanceFilter:(NSInteger)distanceFilter {
  _distanceFilter = distanceFilter;
}

- (NSInteger)distanceFilter {
  return _distanceFilter;
}

#pragma mark -
#pragma mark Location Updates
- (void)startStandardUpdates {
  [_sharedInstance.locationManager startUpdatingLocation];
}

- (void)stopStandardUpdates {
  [_sharedInstance.locationManager stopUpdatingLocation];
}

- (void)startSignificantChangeUpdates {
  [_sharedInstance.locationManager startMonitoringSignificantLocationChanges];
}

- (void)stopSignificantChangeUpdates {
  [_sharedInstance.locationManager stopMonitoringSignificantLocationChanges];
}

#pragma mark -
#pragma mark Location Coordinates
- (BOOL)hasAcquiredLocation {
  if (_sharedInstance.currentLocation) return YES;
  else return NO;
}

- (CGFloat)latitude {
  return self.currentLocation.coordinate.latitude;
}

- (CGFloat)longitude {
  return self.currentLocation.coordinate.longitude;
}


#pragma mark CLLocationManagerDelegate
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
  // If it's a relatively recent event, turn off updates to save power
  NSDate* eventDate = newLocation.timestamp;
  
  NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
  if (abs(howRecent) < 15.0)
  {
    self.oldLocation = oldLocation;
    self.currentLocation = newLocation;
    
    NSLog(@"latitude %+.6f, longitude %+.6f\n", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    // Fire notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationAcquired object:nil];
  }
}


#pragma mark Memory Management
+ (id)allocWithZone:(NSZone *)zone {
  @synchronized(self) {
    if (_sharedInstance == nil) {
      _sharedInstance = [super allocWithZone:zone];
      return _sharedInstance;  // assignment and return on first allocation
    }
  }
  return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
  return self;
}

- (id)retain {
  return self;
}

- (unsigned)retainCount {
  return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
  // do nothing
}

- (id)autorelease {
  return self;
}


@end

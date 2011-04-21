//
//  MapViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PSViewController.h"

@class Nearby;

@interface MapViewController : PSViewController <MKMapViewDelegate> {
  MKMapView *_mapView;
  Nearby *_nearbyPlace;
}

@property (nonatomic, retain) Nearby *nearbyPlace;

- (void)dismiss;

@end

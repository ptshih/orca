//
//  NearbyCell.h
//  Kupo
//
//  Created by Peter Shih on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "PSCell.h"

@interface NearbyCell : PSCell <MKMapViewDelegate> {
  MKMapView *_mapView;
  MKCoordinateRegion _mapRegion;
}

- (void)loadMap;

@end

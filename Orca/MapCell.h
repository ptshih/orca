//
//  MapCell.h
//  Orca
//
//  Created by Peter Shih on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MessageCell.h"

@interface MapCell : MessageCell <MKMapViewDelegate> {
  MKMapView *_mapView;
  MKCoordinateRegion _mapRegion;
}

- (void)loadMapWithMessage:(Message *)message;

@end

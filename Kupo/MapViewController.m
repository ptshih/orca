//
//  MapViewController.m
//  Kupo
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "Nearby.h"

@implementation MapViewController

@synthesize nearbyPlace = _nearbyPlace;


- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
  _mapView.delegate = self;
  [self.view addSubview:_mapView];
  
  // Dismiss button
  UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
  dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  dismissButton.frame = CGRectMake(0, 0, 320, 44);
  [dismissButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:dismissButton];
  
//  UIView *dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//  dismissView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//  [self.view addSubview:dismissView];
//  UITapGestureRecognizer *dismissGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
//  dismissGesture.numberOfTapsRequired = 1;
//  [dismissView addGestureRecognizer:dismissGesture];
//  [dismissGesture release];
//  [dismissView release];
  
  // zoom to place
  MKCoordinateRegion mapRegion;
  mapRegion.center.latitude = [self.nearbyPlace.lat floatValue];
  mapRegion.center.longitude = [self.nearbyPlace.lng floatValue];
  mapRegion.span.latitudeDelta = 0.01;
  mapRegion.span.longitudeDelta = 0.01;
  
  [_mapView setRegion:mapRegion animated:YES];
  NSArray *oldAnnotations = [_mapView annotations];
  [_mapView removeAnnotations:oldAnnotations];
  
  [_mapView addAnnotation:self.nearbyPlace];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
  RELEASE_SAFELY(_mapView);
  RELEASE_SAFELY(_nearbyPlace);
  [super dealloc];
}

@end
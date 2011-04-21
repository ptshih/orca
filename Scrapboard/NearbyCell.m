//
//  NearbyCell.m
//  Scrapboard
//
//  Created by Peter Shih on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbyCell.h"
#import "Nearby.h"
#import "MapViewController.h"

@implementation NearbyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    
    self.textLabel.numberOfLines = 0;
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(MARGIN_X, MARGIN_Y, 120, 100)];
    _mapView.layer.cornerRadius = 5.0;
    _mapView.layer.masksToBounds = YES;
    _mapView.layer.borderColor = [SEPARATOR_COLOR CGColor];
    _mapView.layer.borderWidth = 1.0;
    _mapView.delegate = self;
    [self.contentView addSubview:_mapView];
  }
  return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = touches.anyObject;
  CGPoint location = [touch locationInView:self];
  
  if (CGRectContainsPoint(_mapView.frame, location)) {
    [self showMap];
  } else {
    [super touchesBegan:touches withEvent:event];
  }
}

- (void)showMap {
  MapViewController *mvc = [[MapViewController alloc] init];
  mvc.nearbyPlace = _nearbyPlace;
  mvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
  [APP_DELEGATE.navigationController.modalViewController presentModalViewController:mvc animated:YES];
  [mvc release];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  CGFloat top = MARGIN_Y;
  CGFloat left = _mapView.right + MARGIN_X;
  CGFloat width = self.contentView.width - left - MARGIN_X;
  
  self.textLabel.left = left;
  self.textLabel.top = top;
  [self.textLabel sizeToFitFixedWidth:width];
  self.detailTextLabel.top = self.textLabel.bottom;
  self.detailTextLabel.left = left;
  self.detailTextLabel.width = width;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

+ (CGFloat)rowHeightForObject:(id)object {
  return 110.0;
}

- (void)fillCellWithObject:(id)object {
  Nearby *nearby = (Nearby *)object;
  RELEASE_SAFELY(_nearbyPlace);
  _nearbyPlace = [nearby retain];
  
  self.textLabel.text = nearby.name;
  self.detailTextLabel.text = [NSString stringWithFormat:@"%.2f miles away", [nearby.distance floatValue]];
  
  // zoom to place
  _mapRegion.center.latitude = [nearby.lat floatValue];
  _mapRegion.center.longitude = [nearby.lng floatValue];
  _mapRegion.span.latitudeDelta = 0.0025;
  _mapRegion.span.longitudeDelta = 0.0025;
}

- (void)loadMap {
  [_mapView setRegion:_mapRegion animated:NO];
  
  NSArray *oldAnnotations = [_mapView annotations];
  [_mapView removeAnnotations:oldAnnotations];
  
  [_mapView addAnnotation:_nearbyPlace];
}

+ (PSCellType)cellType {
  return PSCellTypePlain;
}

#pragma mark Map View Delegate methods
//- (void)mapView:(MKMapView *)map regionDidChangeAnimated:(BOOL)animated {
//  NSArray *oldAnnotations = _mapView.annotations;
//  [_mapView removeAnnotations:oldAnnotations];
//  
//  NSArray *weatherItems = [weatherServer weatherItemsForMapRegion:mapView.region maximumCount:4];
//  [_mapView addAnnotations:weatherItems];
//}
//
//- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation {
//  static NSString *AnnotationViewID = @"annotationViewID";
//  
//  WeatherAnnotationView *annotationView =
//  (WeatherAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
//  if (annotationView == nil)
//  {
//    annotationView = [[[WeatherAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
//  }
//  
//  annotationView.annotation = annotation;
//  
//  return annotationView;
//}

- (void)dealloc {
  RELEASE_SAFELY(_nearbyPlace);
  RELEASE_SAFELY(_mapView);
  [super dealloc];
}

@end

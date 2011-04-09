//
//  NearbyCell.m
//  Kupo
//
//  Created by Peter Shih on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbyCell.h"


@implementation NearbyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
    self.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    
    self.textLabel.numberOfLines = 0;
    
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(MARGIN_X, MARGIN_Y, 50, 50)];
    _mapView.layer.cornerRadius = 5.0;
    _mapView.layer.masksToBounds = YES;
    _mapView.layer.borderColor = [SEPARATOR_COLOR CGColor];
    _mapView.layer.borderWidth = 1.0;
    _mapView.delegate = self;
    [self.contentView addSubview:_mapView];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.textLabel.left = _mapView.right + MARGIN_X;
  self.textLabel.width = self.contentView.width - self.textLabel.left - MARGIN_X;
  self.detailTextLabel.left = _mapView.right + MARGIN_X;
  self.detailTextLabel.width = self.contentView.width - self.detailTextLabel.left - MARGIN_X;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

+ (CGFloat)rowHeightForObject:(id)object {
  return 60.0;
}

- (void)fillCellWithObject:(id)object {
  NSDictionary *item = object;
  
  self.textLabel.text = [item valueForKey:@"place_name"];
  self.detailTextLabel.text = [NSString stringWithFormat:@"%.2f miles away", [[item valueForKey:@"place_distance"] floatValue]];
  
  // go to North America
  _mapRegion.center.latitude = [[item valueForKey:@"place_lat"] floatValue];
  _mapRegion.center.longitude = [[item valueForKey:@"place_lng"] floatValue];
  _mapRegion.span.latitudeDelta = 0.005;
  _mapRegion.span.longitudeDelta = 0.005;
}

- (void)loadMap {
  [_mapView setRegion:_mapRegion animated:NO];
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
  RELEASE_SAFELY(_mapView);
  [super dealloc];
}

@end

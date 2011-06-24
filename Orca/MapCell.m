//
//  MapCell.m
//  Orca
//
//  Created by Peter Shih on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapCell.h"

@implementation MapCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Map
    _mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    _mapView.layer.cornerRadius = 5.0;
    _mapView.layer.masksToBounds = YES;
    _mapView.layer.borderColor = [SEPARATOR_COLOR CGColor];
    _mapView.layer.borderWidth = 1.0;
    _mapView.delegate = self;
    [self.contentView addSubview:_mapView];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = _messageLabel.bottom;
  CGFloat left = _quoteView.right + 4.0 + MARGIN_X;
  
  top += 5;
  _mapView.top = top;
  _mapView.left = left;
  _mapView.height = 120;
  _mapView.width = 270;
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  Message *message = (Message *)object;
  
  CGSize desiredSize = CGSizeZero;
  CGFloat textWidth = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - MARGIN_X * 2 - 16 - 4 - MARGIN_X; // minus quote
  
  CGFloat desiredHeight = 0;
  
  // Top margin
  desiredHeight += MARGIN_Y;
  
  // Message
  desiredSize = [UILabel sizeForText:message.message width:textWidth font:NORMAL_FONT numberOfLines:0 lineBreakMode:UILineBreakModeWordWrap];
  desiredHeight += desiredSize.height;
  
  // Map
  desiredHeight += 5;
  desiredHeight += 120;
  desiredHeight += 5;
  
  // Bottom margin
  desiredHeight += MARGIN_Y;
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  [super fillCellWithObject:object];
  
  Message *message = (Message *)object;
  [self loadMapWithMessage:message];
}

- (void)loadMapWithMessage:(Message *)message {
  // zoom to place
  _mapRegion.center.latitude = message.coordinate.latitude;
  _mapRegion.center.longitude = message.coordinate.longitude;
  _mapRegion.span.latitudeDelta = 0.0025;
  _mapRegion.span.longitudeDelta = 0.0025;
  
  [_mapView setRegion:_mapRegion animated:NO];
  NSArray *oldAnnotations = [_mapView annotations];
  [_mapView removeAnnotations:oldAnnotations];
  [_mapView addAnnotation:message];
}

- (void)dealloc {
  RELEASE_SAFELY(_mapView);
  [super dealloc];
}

@end

//
//  Nearby.h
//  Scrapboard
//
//  Created by Peter Shih on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "PSObject.h"

@interface Nearby : PSObject <MKAnnotation> {
  NSString *_id;
  NSString *_name;
  NSNumber *_distance;
  NSNumber *_lat;
  NSNumber *_lng;
  CLLocationCoordinate2D _coordinate;
  
}

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSNumber *distance;
@property (nonatomic, copy) NSNumber *lat;
@property (nonatomic, copy) NSNumber *lng;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

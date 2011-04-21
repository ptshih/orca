//
//  NearbyDataCenter.h
//  Scrapboard
//
//  Created by Peter Shih on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface NearbyDataCenter : PSDataCenter {
  NSMutableArray *_nearbyPlaces;
}

@property (nonatomic, retain) NSMutableArray *nearbyPlaces;

- (void)getNearbyPlaces;

@end
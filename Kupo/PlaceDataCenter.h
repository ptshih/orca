//
//  PlaceDataCenter.h
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface PlaceDataCenter : PSDataCenter {
}

- (void)getPlaces;
- (void)loadMorePlaces;

- (void)loadPlacesFromFixture;

/**
 Serialize server response into Place entities
 */
- (void)serializePlacesWithDictionary:(NSDictionary *)dictionary;

/**
 Fetch Requests
 */
- (NSFetchRequest *)getPlacesFetchRequest;

@end

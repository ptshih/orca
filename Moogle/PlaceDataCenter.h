//
//  PlaceDataCenter.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoogleDataCenter.h"

@interface PlaceDataCenter : MoogleDataCenter {
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
- (NSFetchRequest *)getPlacesFetchRequestWithLimit:(NSInteger)limit;

@end

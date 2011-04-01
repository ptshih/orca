//
//  KupoDataCenter.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoogleDataCenter.h"

@interface KupoDataCenter : MoogleDataCenter {
}

- (void)getKuposForPlaceWithPlaceId:(NSString *)placeId;

- (void)loadKuposFromFixture;

- (void)serializeKuposWithDictionary:(NSDictionary *)dictionary;

/**
 Fetch Requests
 */
- (NSFetchRequest *)getKuposFetchRequestForPlace:(NSString *)placeId;

@end

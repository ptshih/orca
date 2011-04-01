//
//  Place+Serialize.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Place.h"

@interface Place (Serialize)

+ (Place *)addPlaceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

- (void)updatePlaceWithDictionary:(NSDictionary *)dictionary;

@end

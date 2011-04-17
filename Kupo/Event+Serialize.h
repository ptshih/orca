//
//  Event+Serialize.h
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"

@interface Event (Serialize)

+ (Event *)addEventWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

- (Event *)updateEventWithDictionary:(NSDictionary *)dictionary;

@end

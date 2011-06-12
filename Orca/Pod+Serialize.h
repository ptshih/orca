//
//  Pod+Serialize.h
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pod.h"

@interface Pod (Serialize)

+ (Pod *)addPodWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

- (Pod *)updatePodWithDictionary:(NSDictionary *)dictionary;

@end

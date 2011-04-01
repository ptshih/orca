//
//  Kupo+Serialize.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Kupo.h"

@interface Kupo (Serialize)

+ (Kupo *)addKupoWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

@end

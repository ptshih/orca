//
//  Snap+Serialize.h
//  Scrapboard
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Snap.h"

@interface Snap (Serialize)

+ (Snap *)addSnapWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

- (Snap *)updateSnapWithDictionary:(NSDictionary *)dictionary;

@end

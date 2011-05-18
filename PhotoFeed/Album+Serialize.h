//
//  Album+Serialize.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Album.h"

@interface Album (Serialize)

// This is used for sectioning in tableview
- (NSString *)daysAgo;

+ (Album *)addAlbumWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

- (Album *)updateAlbumWithDictionary:(NSDictionary *)dictionary;

@end

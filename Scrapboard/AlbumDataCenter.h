//
//  AlbumDataCenter.h
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface AlbumDataCenter : PSDataCenter {
  NSManagedObjectContext *_context;
}

- (void)getAlbums;

/**
 Serialize server response into Event entities
 */
- (void)serializeAlbumsWithDictionary:(NSDictionary *)dictionary;

/**
 Fetch Requests
 */
- (NSFetchRequest *)getAlbumsFetchRequest;

@end

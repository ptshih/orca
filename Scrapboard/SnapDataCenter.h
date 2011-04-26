//
//  SnapDataCenter.h
//  Scrapboard
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface SnapDataCenter : PSDataCenter {
  NSManagedObjectContext *_context;
}

- (void)getSnapsForAlbumWithAlbumId:(NSString *)albumId;

/**
 Serialize server response into Snap entities
 */
- (void)serializeSnapsWithDictionary:(NSDictionary *)dictionary;

/**
 Fetch Requests
 */
- (NSFetchRequest *)getSnapsFetchRequestWithAlbumId:(NSString *)albumId;


@end

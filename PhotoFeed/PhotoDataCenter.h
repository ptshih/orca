//
//  PhotoDataCenter.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface PhotoDataCenter : PSDataCenter {
}

- (void)getPhotosForAlbumId:(NSString *)albumId;

/**
 Serialize server response into Photo entities
 */
- (void)serializePhotosWithDictionary:(NSDictionary *)dictionary forAlbumId:(NSString *)albumId;

/**
 Fetch Requests
 */
- (NSFetchRequest *)fetchPhotosForAlbumId:(NSString *)albumId withLimit:(NSUInteger)limit andOffset:(NSUInteger)offset;


@end

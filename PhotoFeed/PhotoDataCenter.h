//
//  PhotoDataCenter.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@class Photo;

@interface PhotoDataCenter : PSDataCenter {
}

- (void)getPhotosForAlbumId:(NSString *)albumId;

/**
 Serialize server response into Photo entities
 */
- (void)serializePhotosWithDictionary:(NSDictionary *)dictionary forAlbumId:(NSString *)albumId inContext:(NSManagedObjectContext *)context;

- (void)serializePhotosWithPayload:(NSDictionary *)payload; // thread
- (void)serializePhotosFinished;

/**
 Serialize comments
 */
- (void)serializeCommentsWithDictionary:(NSDictionary *)dictionary forPhoto:(Photo *)photo inContext:(NSManagedObjectContext *)context;

/**
 Fetch Requests
 */
- (NSFetchRequest *)fetchPhotosForAlbumId:(NSString *)albumId withLimit:(NSUInteger)limit andOffset:(NSUInteger)offset;


@end

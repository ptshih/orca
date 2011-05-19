//
//  PhotoDataCenter.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"
#import "Album.h"

@interface PhotoDataCenter : PSDataCenter {
  NSManagedObjectContext *_context;
  Album *_album;
}

@property (nonatomic, assign) Album *album;

- (void)getPhotosForAlbum:(Album *)album;

/**
 Serialize server response into Photo entities
 */
- (void)serializePhotosWithDictionary:(NSDictionary *)dictionary;

/**
 Fetch Requests
 */
- (NSFetchRequest *)fetchPhotosForAlbum:(Album *)album;


@end

//
//  AlbumDataCenter.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface AlbumDataCenter : PSDataCenter {
  NSUInteger _responsesToBeParsed;
}

+ (AlbumDataCenter *)defaultCenter;

- (void)getAlbums;

/**
 Serialize server response into Album entities
 */
- (void)serializeAlbumsWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

- (void)serializeAlbumsWithResponse:(id)response; // thread
- (void)serializeAlbumsFinished;

/**
 Fetch Requests
 */
- (NSFetchRequest *)fetchAlbumsWithTemplate:(NSString *)fetchTemplate andSubstitutionVariables:(NSDictionary *)substitutionVariables andLimit:(NSUInteger)limit andOffset:(NSUInteger)offset;

@end

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
}

+ (AlbumDataCenter *)defaultCenter;

/**
 Get albums from Server
 */
- (void)getAlbums;

/**
 Serialize server response into Album entities
 */
- (void)serializeAlbumsWithRequest:(ASIHTTPRequest *)request;
- (void)serializeAlbumsFinishedWithRequest:(ASIHTTPRequest *)request;
- (void)serializeAlbumsWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context;



/**
 Fetch Requests
 */
- (NSFetchRequest *)fetchAlbumsWithTemplate:(NSString *)fetchTemplate andSubstitutionVariables:(NSDictionary *)substitutionVariables andLimit:(NSUInteger)limit andOffset:(NSUInteger)offset;

@end

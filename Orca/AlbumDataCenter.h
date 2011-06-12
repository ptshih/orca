//
//  AlbumDataCenter.h
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface AlbumDataCenter : PSDataCenter {
  NSUInteger _pendingRequestsToParse;
}

+ (AlbumDataCenter *)defaultCenter;

/**
 Get albums from Server
 */
- (void)getAlbums;
- (void)getAlbumsForFriendIds:(NSArray *)friendIds;

/**
 Serialize server response into Album entities
 */
- (void)serializeAlbumsWithRequest:(ASIHTTPRequest *)request;
- (void)serializeAlbumsFinishedWithRequest:(ASIHTTPRequest *)request;
- (void)serializeAlbumsWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context;



/**
 Fetch Requests
 */
- (NSFetchRequest *)fetchAlbumsWithTemplate:(NSString *)fetchTemplate andSortDescriptors:(NSArray *)sortDescriptors andSubstitutionVariables:(NSDictionary *)substitutionVariables andLimit:(NSUInteger)limit andOffset:(NSUInteger)offset;

@end

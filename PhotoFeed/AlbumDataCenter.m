//
//  AlbumDataCenter.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDataCenter.h"
#import "Album.h"
#import "Album+Serialize.h"

@implementation AlbumDataCenter

- (id)init {
  self = [super init];
  if (self) {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
    _context = [LICoreDataStack sharedManagedObjectContext];
  }
  return self;
}

- (void)getAlbums {
//  curl -F "batch=[ {'method': 'GET', 'name' : 'get-friends', 'relative_url': 'me/friends', 'omit_response_on_success' : true}, {'method': 'GET', 'name' : 'get-albums', 'depends_on':'get-friends', 'relative_url': 'albums?ids=me,{result=get-friends:$.data..id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=100', 'omit_response_on_success' : false} ]" https://graph.facebook.com
  
  // Apply since if exists
  NSDate *since = [[NSUserDefaults standardUserDefaults] valueForKey:@"albums.since"];
  
  NSMutableDictionary *friendsDict = [NSMutableDictionary dictionary];
  [friendsDict setValue:@"GET" forKey:@"method"];
  [friendsDict setValue:@"get-friends" forKey:@"name"];
  [friendsDict setValue:@"me/friends" forKey:@"relative_url"];
  [friendsDict setValue:[NSNumber numberWithBool:YES] forKey:@"omit_response_on_success"];
  
  NSMutableDictionary *albumsDict = [NSMutableDictionary dictionary];
  [albumsDict setValue:@"GET" forKey:@"method"];
  [albumsDict setValue:@"get-albums" forKey:@"name"];
  [albumsDict setValue:@"albums?ids=me,{result=get-friends:$.data..id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=100" forKey:@"relative_url"];
  [albumsDict setValue:[NSNumber numberWithBool:NO] forKey:@"omit_response_on_success"];
  
  NSArray *batchArray = [NSArray arrayWithObjects:friendsDict, albumsDict, nil];
  NSString *batchJSON = [batchArray JSONRepresentation];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:batchJSON forKey:@"batch"];
  
  [self sendFacebookBatchRequestWithParams:params andUserInfo:nil];
}

- (void)serializeAlbumsWithDictionary:(NSDictionary *)dictionary {
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
  
  NSArray *sortedEntities = [[dictionary valueForKey:@"data"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSMutableArray *sortedEntityIds = [NSMutableArray array];
  for (NSDictionary *entityDict in sortedEntities) {
    [sortedEntityIds addObject:[entityDict valueForKey:@"id"]];
  }
  
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Album" inManagedObjectContext:_context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedEntityIds]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease]]];
  
  
  NSError *error = nil;
  NSArray *foundEntities = [_context executeFetchRequest:fetchRequest error:&error];
  
  int i = 0;
  for (NSDictionary *entityDict in sortedEntities) {
    if ([foundEntities count] > 0 && i < [foundEntities count] && [[entityDict valueForKey:@"id"] isEqualToString:[[foundEntities objectAtIndex:i] id]]) {
//      DLog(@"found duplicated album with id: %@", [[foundEntities objectAtIndex:i] id]);
      [[foundEntities objectAtIndex:i] updateAlbumWithDictionary:entityDict];
      i++;
    } else {
      // Insert
      [Album addAlbumWithDictionary:entityDict inContext:_context];
    }
  }
  
  // Save to Core Data
  [LICoreDataStack saveSharedContextIfNeeded];
//  if ([_context hasChanges]) {
//    if (![_context save:&error]) {
//      // CoreData ERROR!
//      abort(); // NOTE: DO NOT SHIP
//    }
//  }
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request withResponse:(id)response {
  // Process the batched results
  NSArray *allValues = [response allValues];
  for (NSDictionary *valueDict in allValues) {
    [self serializeAlbumsWithDictionary:valueDict];
  }
  [super dataCenterRequestFinished:request withResponse:response];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  [super dataCenterRequestFailed:request withError:error];
}

- (NSFetchRequest *)getAlbumsFetchRequest {
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
  NSFetchRequest *fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getAlbums" substitutionVariables:[NSDictionary dictionary]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setFetchBatchSize:20];
  [fetchRequest setFetchLimit:100];
  return fetchRequest;
}

@end

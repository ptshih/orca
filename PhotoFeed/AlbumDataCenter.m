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

static AlbumDataCenter *_defaultCenter = nil;

@implementation AlbumDataCenter

+ (AlbumDataCenter *)defaultCenter {
  if (!_defaultCenter) {
    _defaultCenter = [[self alloc] init];
  }
  return _defaultCenter;
}

- (id)init {
  self = [super init];
  if (self) {
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
    _context = [PSCoreDataStack sharedManagedObjectContext];
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
#warning fetch these in a background thread
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
  [PSCoreDataStack saveSharedContextIfNeeded];
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request withResponseData:(NSData *)responseData {
  // Process the batched results in a BG thread
  [[PSParserStack sharedParser] parseData:responseData withDelegate:self];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFail:withError:)]) {
    [_delegate performSelector:@selector(dataCenterDidFail:withError:) withObject:request withObject:error];
  }
}

- (void)parseFinishedWithResponse:(id)response {
#warning check for Facebook errors
  if ([response isKindOfClass:[NSArray class]]) {
    [[PSParserStack sharedParser] parseData:[[[response lastObject] objectForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding] withDelegate:self];
  } else {
    NSArray *allValues = [response allValues];
    for (NSDictionary *valueDict in allValues) {
      [self serializeAlbumsWithDictionary:valueDict];
    }
    
    // Inform Delegate
    if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFinish:withResponse:)]) {
      [_delegate performSelector:@selector(dataCenterDidFinish:withResponse:) withObject:nil withObject:response];
    }
  }
}

- (NSFetchRequest *)fetchAlbumsWithTemplate:(NSString *)fetchTemplate andSubstitutionVariables:(NSDictionary *)substitutionVariables andLimit:(NSUInteger)limit andOffset:(NSUInteger)offset {
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
  NSFetchRequest *fetchRequest = [[PSCoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:fetchTemplate substitutionVariables:substitutionVariables];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setFetchBatchSize:10];
  [fetchRequest setFetchLimit:limit];
  [fetchRequest setFetchOffset:offset];
  return fetchRequest;
}

@end

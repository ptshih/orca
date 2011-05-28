
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
    _pendingRequestsToParse = 0;
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
  }
  return self;
}

#pragma mark -
#pragma mark Prepare Request
- (void)getAlbums {
  //  curl -F "batch=[ {'method': 'GET', 'name' : 'get-friends', 'relative_url': 'me/friends', 'omit_response_on_success' : true}, {'method': 'GET', 'name' : 'get-albums', 'depends_on':'get-friends', 'relative_url': 'albums?ids=me,{result=get-friends:$.data..id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=100', 'omit_response_on_success' : false} ]" https://graph.facebook.com
  
  /*
   curl -F "access_token=D1LgK2fmX11PjBMtys6iI68Kei67r5jPCuB24sf1IrM.eyJpdiI6InFjQ0FPbHVQRDl0b3hzMGZZVWFiSGcifQ.jKiEolLuK1lIgKOnC7Q5_iYWrv-4VEKD-X-zREhyn7r8h2ROyuOJ8yDWn5usdvcbDjkerlvTYVX5A1q3KEKPDSABn0i3nK9pC5KmX9S0clAoV6yv8AGvrBy6NXRleCoJ" -F "batch=[ {'method': 'GET', 'name' : 'get-friends', 'relative_url': 'me/friends?fields=id,name', 'omit_response_on_success' : true}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[0:199:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[200:399:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[400:599:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[600:799:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[800:999:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[1000:1199:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false} ]"
   */
  
  /*
   Multiqueries FQL
   https://api.facebook.com/method/fql.multiquery?format=json&queries=
   
   {"query1":"SELECT uid2 FROM friend WHERE uid1 = me()", "query2":"SELECT aid,owner,cover_pid,name,description,location,size,type,modified_major,created,modified,can_upload FROM album WHERE owner IN (SELECT uid2 FROM #query1)"}
   
   */
  
  
  // This is retarded... if the user has more than batchSize friends, we'll just fire off multiple requests
  NSURL *albumsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.facebook.com/method/fql.query"]];
  
#warning when applying this since, if the user adds new friends, we need to do a cold query for that friend's albums
  // Apply since if exists
  NSDate *sinceDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"albums.since"];
  NSTimeInterval since = [sinceDate timeIntervalSince1970] - SINCE_SAFETY_NET;
    
  // Get batch size/count
  NSArray *friends = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"facebookFriends"] valueForKey:@"id"];
  NSInteger batchSize = 150;
  NSInteger batchCount = ceil((CGFloat)[friends count] / (CGFloat)batchSize);
  NSRange range = NSMakeRange(0, 0);

  // ME
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:@"json" forKey:@"format"];
  [params setValue:[NSString stringWithFormat:@"SELECT aid,object_id,owner,name,description,location,size,type,modified_major,created,modified,can_upload FROM album WHERE owner = me() AND modified_major > %0.0f", since] forKey:@"query"];
  _pendingRequestsToParse++;
  [self sendRequestWithURL:albumsUrl andMethod:POST andHeaders:nil andParams:params andUserInfo:nil];
  
  // FRIENDS
  for (int i=0; i<batchCount; i++) {
    NSMutableDictionary *friendParams = [NSMutableDictionary dictionary];
    [friendParams setValue:@"json" forKey:@"format"];
    
    NSInteger remainingFriends = [friends count] - (i * batchSize);
    NSInteger length = (batchSize > remainingFriends) ? remainingFriends : batchSize;
    range = NSMakeRange(i * batchSize, length);
    NSArray *batchFriends = [friends subarrayWithRange:range];
    
    [friendParams setValue:[NSString stringWithFormat:@"SELECT aid,object_id,owner,cover_pid,name,description,location,size,type,modified_major,created,modified,can_upload FROM album WHERE owner IN (%@) AND modified_major > %0.0f", [batchFriends componentsJoinedByString:@","], since] forKey:@"query"];
    
    _pendingRequestsToParse++;
    [self sendRequestWithURL:albumsUrl andMethod:POST andHeaders:nil andParams:friendParams andUserInfo:nil];
  }
}

#pragma mark -
#pragma mark Serialization
- (void)serializeAlbumsWithRequest:(ASIHTTPRequest *)request {
  NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
  
  // Parse the JSON
  id response = [[request responseData] JSONValue];
  
  // Process the Response for Albums
  if ([response isKindOfClass:[NSArray class]]) {
    [self serializeAlbumsWithArray:response inContext:context];
  }
  
  // Save to Core Data
  [PSCoreDataStack saveInContext:context];
  [context release];
  
  [self performSelectorOnMainThread:@selector(serializeAlbumsFinishedWithRequest:) withObject:request waitUntilDone:NO];
}

- (void)serializeAlbumsFinishedWithRequest:(ASIHTTPRequest *)request {
  _pendingRequestsToParse--;
  
  // Inform Delegate if all responses are parsed
  if (_pendingRequestsToParse == 0 && _delegate && [_delegate respondsToSelector:@selector(dataCenterDidFinish:withResponse:)]) {
    [_delegate performSelector:@selector(dataCenterDidFinish:withResponse:) withObject:request withObject:nil];
    [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"albums.since"];
  }
}

#pragma mark Core Data Serialization
- (void)serializeAlbumsWithArray:(NSArray *)array inContext:(NSManagedObjectContext *)context {
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"object_id" ascending:YES];
  
  NSArray *sortedEntities = [array sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSMutableArray *sortedEntityIds = [NSMutableArray array];
  for (NSDictionary *entityDict in sortedEntities) {
    [sortedEntityIds addObject:[entityDict valueForKey:@"object_id"]];
  }
  
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Album" inManagedObjectContext:context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedEntityIds]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease]]];
  
  
  NSError *error = nil;
  NSArray *foundEntities = [context executeFetchRequest:fetchRequest error:&error];
  
  int i = 0;
  for (NSDictionary *entityDict in sortedEntities) {
    id objectId = [entityDict valueForKey:@"object_id"];
    if ([objectId isKindOfClass:[NSNumber class]]) {
      objectId = [objectId stringValue];
    }
    
    if ([foundEntities count] > 0 && i < [foundEntities count] && [objectId isEqualToString:[[foundEntities objectAtIndex:i] id]]) {
      //      DLog(@"found duplicated album with id: %@", [[foundEntities objectAtIndex:i] id]);
      [[foundEntities objectAtIndex:i] updateAlbumWithDictionary:entityDict];
      i++;
    } else {
      // Insert
      [Album addAlbumWithDictionary:entityDict inContext:context];
    }
  }
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  // Process the batched results in a BG thread
#ifdef USE_JESSA_FIXTURES
  NSString *path = [[NSBundle mainBundle] pathForResource:@"jessa" ofType:@"json"];
  NSData *tmpData = [NSData dataWithContentsOfFile:path];
#else
  NSInvocationOperation *parseOp = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(serializeAlbumsWithRequest:) object:request];
  [[PSParserStack sharedParser] addOperation:parseOp];
#endif
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFail:withError:)]) {
    [_delegate performSelector:@selector(dataCenterDidFail:withError:) withObject:request withObject:[request error]];
  }
}

#pragma mark -
#pragma mark Fetch Request
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

- (void)dealloc {
  [super dealloc];
}

@end

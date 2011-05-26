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
  }
  return self;
}

- (void)getAlbums {
  //  curl -F "batch=[ {'method': 'GET', 'name' : 'get-friends', 'relative_url': 'me/friends', 'omit_response_on_success' : true}, {'method': 'GET', 'name' : 'get-albums', 'depends_on':'get-friends', 'relative_url': 'albums?ids=me,{result=get-friends:$.data..id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=100', 'omit_response_on_success' : false} ]" https://graph.facebook.com
  
  /*
   curl -F "access_token=D1LgK2fmX11PjBMtys6iI68Kei67r5jPCuB24sf1IrM.eyJpdiI6InFjQ0FPbHVQRDl0b3hzMGZZVWFiSGcifQ.jKiEolLuK1lIgKOnC7Q5_iYWrv-4VEKD-X-zREhyn7r8h2ROyuOJ8yDWn5usdvcbDjkerlvTYVX5A1q3KEKPDSABn0i3nK9pC5KmX9S0clAoV6yv8AGvrBy6NXRleCoJ" -F "batch=[ {'method': 'GET', 'name' : 'get-friends', 'relative_url': 'me/friends?fields=id,name', 'omit_response_on_success' : true}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[0:199:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[200:399:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[400:599:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[600:799:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[800:999:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false}, {'method': 'GET', 'depends_on':'get-friends', 'relative_url': 'albums?ids={result=get-friends:$.data[1000:1199:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0', 'omit_response_on_success' : false} ]"
   */
  
  // Apply since if exists
#warning when applying this since, if the user adds new friends, we need to do a cold query for that friend's albums
  NSDate *since = [[NSUserDefaults standardUserDefaults] valueForKey:@"albums.since"];
  
  NSMutableArray *batchArray = [[NSMutableArray alloc] init];
  
  NSMutableDictionary *friendsDict = [NSMutableDictionary dictionary];
  [friendsDict setValue:@"GET" forKey:@"method"];
  [friendsDict setValue:@"get-friends" forKey:@"name"];
  [friendsDict setValue:@"me/friends" forKey:@"relative_url"];
  [friendsDict setValue:[NSNumber numberWithBool:YES] forKey:@"omit_response_on_success"];
  
  // Add friends dict to batch
  [batchArray addObject:friendsDict];
  
  NSInteger batch = 200;
  NSInteger end = ceil((CGFloat)[[[NSUserDefaults standardUserDefaults] arrayForKey:@"facebookFriends"] count] / (CGFloat)batch);
  NSString *me = @"me,";
  
  for (int i=0; i<end; i++) {
    if (i > 0) me = @"";
    NSString *relativeUrl = [NSString stringWithFormat:@"albums?ids=%@{result=get-friends:$.data[%d:%d:1].id}&fields=id,from,name,description,type,created_time,updated_time,cover_photo,count&limit=0&since=%0.0f", me, (i*batch), (i*batch + batch - 1), ([since timeIntervalSince1970] - SINCE_SAFETY_NET)];
    
    NSMutableDictionary *albumsDict = [[NSMutableDictionary alloc] init];
    [albumsDict setValue:@"GET" forKey:@"method"];
    [albumsDict setValue:relativeUrl forKey:@"relative_url"];
    [albumsDict setValue:[NSNumber numberWithBool:NO] forKey:@"omit_response_on_success"];
    [batchArray addObject:albumsDict];
    [albumsDict release];
  }

  NSString *batchJSON = [batchArray JSONRepresentation];
  [batchArray release];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:batchJSON forKey:@"batch"];
  
  [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:@"albums.since"];
  [self sendFacebookBatchRequestWithParams:params andUserInfo:nil];
}

- (void)serializeAlbumsWithResponse:(id)response {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
  NSArray *allValues = [response allValues];
  for (NSDictionary *valueDict in allValues) {
    [self serializeAlbumsWithDictionary:valueDict inContext:context];
  }
  // Save to Core Data
  [PSCoreDataStack saveInContext:context];
  [context release];
  
  [self performSelectorOnMainThread:@selector(serializeAlbumsFinished) withObject:nil waitUntilDone:NO];
  [pool release];
}

- (void)serializeAlbumsFinished {
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFinish:withResponse:)]) {
    [_delegate performSelector:@selector(dataCenterDidFinish:withResponse:) withObject:nil withObject:nil];
  }
}

- (void)serializeAlbumsWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
  
  NSArray *sortedEntities = [[dictionary valueForKey:@"data"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSMutableArray *sortedEntityIds = [NSMutableArray array];
  for (NSDictionary *entityDict in sortedEntities) {
    [sortedEntityIds addObject:[entityDict valueForKey:@"id"]];
  }
  
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Album" inManagedObjectContext:context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedEntityIds]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease]]];
  
  
  NSError *error = nil;
  NSArray *foundEntities = [context executeFetchRequest:fetchRequest error:&error];
  
  int i = 0;
  for (NSDictionary *entityDict in sortedEntities) {
    if ([foundEntities count] > 0 && i < [foundEntities count] && [[entityDict valueForKey:@"id"] isEqualToString:[[foundEntities objectAtIndex:i] id]]) {
      //      DLog(@"found duplicated album with id: %@", [[foundEntities objectAtIndex:i] id]);
      [[foundEntities objectAtIndex:i] updateAlbumWithDictionary:entityDict];
      i++;
    } else {
      // Insert
      [Album addAlbumWithDictionary:entityDict inContext:context];
    }
  }
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request withResponseData:(NSData *)responseData {
  // Process the batched results in a BG thread
#warning test fixtures
#ifdef USE_JESSA_FIXTURES
  NSString *path = [[NSBundle mainBundle] pathForResource:@"jessa" ofType:@"json"];
  NSData *tmpData = [NSData dataWithContentsOfFile:path];
  [[PSParserStack sharedParser] parseData:tmpData withDelegate:self andUserInfo:nil];
#else
  [[PSParserStack sharedParser] parseData:responseData withDelegate:self andUserInfo:nil];
#endif
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFail:withError:)]) {
    [_delegate performSelector:@selector(dataCenterDidFail:withError:) withObject:request withObject:error];
  }
}

- (void)parseFinishedWithResponse:(id)response andUserInfo:(NSDictionary *)userInfo {
#warning check for Facebook errors
  // Traverse Array if batch
  if ([response isKindOfClass:[NSArray class]]) {
    for (id res in response) {
      if ([res notNil] && [res isKindOfClass:[NSDictionary class]]) {
        [[PSParserStack sharedParser] parseData:[[res objectForKey:@"body"] dataUsingEncoding:NSUTF8StringEncoding] withDelegate:self andUserInfo:nil];
      }
    }
  } else {
    [self performSelectorInBackground:@selector(serializeAlbumsWithResponse:) withObject:response];
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

- (void)dealloc {
  [super dealloc];
}

@end

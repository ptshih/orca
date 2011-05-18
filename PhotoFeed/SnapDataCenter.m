//
//  SnapDataCenter.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SnapDataCenter.h"
#import "Snap.h"
#import "Snap+Serialize.h"

@implementation SnapDataCenter

- (id)init {
  self = [super init];
  if (self) {
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
    _context = [LICoreDataStack sharedManagedObjectContext];
  }
  return self;
}

- (void)getSnapsForAlbumWithAlbumId:(NSString *)albumId {
  NSURL *snapsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_BASE_URL, SNAPS_ENDPOINT]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:albumId forKey:@"album_id"];
  
  [self sendRequestWithURL:snapsUrl andMethod:GET andHeaders:nil andParams:params andUserInfo:nil];
}

- (void)serializeSnapsWithDictionary:(NSDictionary *)dictionary {
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
  
  NSArray *sortedEntities = [[dictionary valueForKey:@"data"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSMutableArray *sortedEntityIds = [NSMutableArray array];
  for (NSDictionary *entityDict in sortedEntities) {
    [sortedEntityIds addObject:[entityDict valueForKey:@"id"]];
  }
  
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Snap" inManagedObjectContext:_context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedEntityIds]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease]]];
  
  
  NSError *error = nil;
  NSArray *foundEntities = [_context executeFetchRequest:fetchRequest error:&error];
  
  int i = 0;
  for (NSDictionary *entityDict in sortedEntities) {
    if ([foundEntities count] > 0 && i < [foundEntities count] && [[entityDict valueForKey:@"id"] isEqualToString:[[foundEntities objectAtIndex:i] id]]) {
//      DLog(@"found duplicated snap with id: %@", [[foundEntities objectAtIndex:i] id]);
      [[foundEntities objectAtIndex:i] updateSnapWithDictionary:entityDict];
      i++;
    } else {
      // Insert
      [Snap addSnapWithDictionary:entityDict inContext:_context];
    }
  }
  
  // Save to Core Data
  if ([_context hasChanges]) {
    if (![_context save:&error]) {
      // CoreData ERROR!
      abort(); // NOTE: DO NOT SHIP
    }
  }
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request withResponse:(id)response {
  [self serializeSnapsWithDictionary:response];
  [super dataCenterRequestFinished:request withResponse:response];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  [super dataCenterRequestFailed:request withError:error];
}

- (NSFetchRequest *)getSnapsFetchRequestWithAlbumId:(NSString *)albumId {
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
  NSFetchRequest *fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getSnapsForAlbum" substitutionVariables:[NSDictionary dictionaryWithObject:albumId forKey:@"desiredAlbumId"]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  return fetchRequest;
}

@end

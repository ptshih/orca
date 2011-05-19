//
//  PhotoDataCenter.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoDataCenter.h"
#import "Photo.h"
#import "Photo+Serialize.h"

@implementation PhotoDataCenter

@synthesize album = _album;

- (id)init {
  self = [super init];
  if (self) {
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
    _context = [LICoreDataStack sharedManagedObjectContext];
  }
  return self;
}

- (void)getPhotosForAlbum:(Album *)album {
  self.album = album;
  NSURL *photosUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/photos", FB_GRAPH, album.id]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [self sendRequestWithURL:photosUrl andMethod:GET andHeaders:nil andParams:params andUserInfo:nil];
}

- (void)serializePhotosWithDictionary:(NSDictionary *)dictionary {
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
  
  NSArray *sortedEntities = [[dictionary valueForKey:@"data"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSMutableArray *sortedEntityIds = [NSMutableArray array];
  for (NSDictionary *entityDict in sortedEntities) {
    [sortedEntityIds addObject:[entityDict valueForKey:@"id"]];
  }
  
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:_context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedEntityIds]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease]]];
  
  NSMutableSet *photos = [NSMutableSet set];
  
  NSError *error = nil;
  NSArray *foundEntities = [_context executeFetchRequest:fetchRequest error:&error];
  
  int i = 0;
  for (NSDictionary *entityDict in sortedEntities) {
    if ([foundEntities count] > 0 && i < [foundEntities count] && [[entityDict valueForKey:@"id"] isEqualToString:[[foundEntities objectAtIndex:i] id]]) {
//      DLog(@"found duplicated photo with id: %@", [[foundEntities objectAtIndex:i] id]);
      [[foundEntities objectAtIndex:i] updatePhotoWithDictionary:entityDict];
      i++;
    } else {
      // Insert
      [photos addObject:[Photo addPhotoWithDictionary:entityDict inContext:_context]];
    }
  }
  
  // Add new photos to current album
  if (_album) {
    [_album addPhotos:photos];
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
  [self serializePhotosWithDictionary:response];
  [super dataCenterRequestFinished:request withResponse:response];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  [super dataCenterRequestFailed:request withError:error];
}

- (NSFetchRequest *)fetchPhotosForAlbum:(Album *)album {
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES] autorelease];
  NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
  NSFetchRequest *fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getPhotosForAlbum" substitutionVariables:[NSDictionary dictionaryWithObject:album forKey:@"desiredAlbum"]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setFetchBatchSize:10];
  [fetchRequest setFetchLimit:20];
  return fetchRequest;
}

@end

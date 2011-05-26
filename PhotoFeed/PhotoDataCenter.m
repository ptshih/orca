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
#import "Comment.h"
#import "Comment+Serialize.h"

@implementation PhotoDataCenter

- (id)init {
  self = [super init];
  if (self) {
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
  }
  return self;
}

- (void)getPhotosForAlbumId:(NSString *)albumId {
  NSURL *photosUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/photos", FB_GRAPH, albumId]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:@"0" forKey:@"limit"];
  
  [self sendRequestWithURL:photosUrl andMethod:GET andHeaders:nil andParams:params andUserInfo:[NSDictionary dictionaryWithObject:albumId forKey:@"albumId"]];
}

- (void)serializePhotosWithPayload:(NSDictionary *)payload {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
  
  [self serializePhotosWithDictionary:[payload objectForKey:@"response"] forAlbumId:[payload objectForKey:@"albumId"] inContext:context];
  
  // Save to Core Data
  [PSCoreDataStack saveInContext:context];
  [context release];
  
  [self performSelectorOnMainThread:@selector(serializePhotosFinished) withObject:nil waitUntilDone:NO];
  [pool release];
}

- (void)serializePhotosFinished {
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFinish:withResponse:)]) {
    [_delegate performSelector:@selector(dataCenterDidFinish:withResponse:) withObject:nil withObject:nil];
  }
}

- (void)serializePhotosWithDictionary:(NSDictionary *)dictionary forAlbumId:(NSString *)albumId inContext:(NSManagedObjectContext *)context {
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
  
  NSArray *sortedEntities = [[dictionary valueForKey:@"data"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSMutableArray *sortedEntityIds = [NSMutableArray array];
  for (NSDictionary *entityDict in sortedEntities) {
    [sortedEntityIds addObject:[entityDict valueForKey:@"id"]];
  }
  
  NSFetchRequest *fetchRequest = [[[NSFetchRequest alloc] init] autorelease];
  [fetchRequest setEntity:[NSEntityDescription entityForName:@"Photo" inManagedObjectContext:context]];
  [fetchRequest setPredicate:[NSPredicate predicateWithFormat: @"(id IN %@)", sortedEntityIds]];
  [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"id" ascending:YES] autorelease]]];
  
  NSError *error = nil;
  NSArray *foundEntities = [context executeFetchRequest:fetchRequest error:&error];

  Photo *photo = nil;
  int i = 0;
  for (NSDictionary *entityDict in sortedEntities) {
    if ([foundEntities count] > 0 && i < [foundEntities count] && [[entityDict valueForKey:@"id"] isEqualToString:[[foundEntities objectAtIndex:i] id]]) {
      photo = [foundEntities objectAtIndex:i];
      //      DLog(@"found duplicated photo with id: %@", [[foundEntities objectAtIndex:i] id]);
      [photo updatePhotoWithDictionary:entityDict forAlbumId:albumId];
      i++;
    } else {
      // Insert
      photo = [Photo addPhotoWithDictionary:entityDict forAlbumId:albumId inContext:context];
    }
    
    // Serialize Comments
    if ([entityDict objectForKey:@"comments"]) {
      [self serializeCommentsWithDictionary:[entityDict objectForKey:@"comments"] forPhoto:photo inContext:context];
    }
  }
}

- (void)serializeCommentsWithDictionary:(NSDictionary *)dictionary forPhoto:(Photo *)photo inContext:(NSManagedObjectContext *)context {
  NSMutableSet *comments = [NSMutableSet set];
  
  // Check for dupes
  // photo may have existing comments, compare those with the new ones
  // comments don't ever get updated, no need to update, just insert new
  
  NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES];
  NSArray *existingComments = [photo.comments sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
  
  NSArray *newComments = [[dictionary valueForKey:@"data"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

  int i = 0;
  for (NSDictionary *commentDict in newComments) {
    if ([existingComments count] > 0 && i < [existingComments count] && [[commentDict valueForKey:@"id"] isEqualToString:[[existingComments objectAtIndex:i] id]]) {
      // existing comment found
      NSLog(@"found existing comment with id: %@", [[existingComments objectAtIndex:i] id]);
      i++;
    } else {
      [comments addObject:[Comment addCommentWithDictionary:commentDict inContext:context]];
    }
  }
  [photo addComments:comments];
}

#pragma mark -
#pragma mark Request finished
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request withResponseData:(NSData *)responseData {
//  id response = [responseData JSONValue];
  [[PSParserStack sharedParser] parseData:responseData withDelegate:self andUserInfo:request.userInfo];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  // Inform Delegate
  if (_delegate && [_delegate respondsToSelector:@selector(dataCenterDidFail:withError:)]) {
    [_delegate performSelector:@selector(dataCenterDidFail:withError:) withObject:request withObject:error];
  }
}

- (void)parseFinishedWithResponse:(id)response andUserInfo:(NSDictionary *)userInfo {
#warning check for Facebook errors
  NSDictionary *payload = [NSDictionary dictionaryWithObjectsAndKeys:response, @"response", [userInfo objectForKey:@"albumId"], @"albumId", nil];
  [self performSelectorInBackground:@selector(serializePhotosWithPayload:) withObject:payload];
}

#pragma mark -
#pragma mark Fetch Request
- (NSFetchRequest *)fetchPhotosForAlbumId:(NSString *)albumId withLimit:(NSUInteger)limit andOffset:(NSUInteger)offset {
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
  NSFetchRequest *fetchRequest = [[PSCoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getPhotosForAlbum" substitutionVariables:[NSDictionary dictionaryWithObject:albumId forKey:@"desiredAlbumId"]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setFetchBatchSize:10];
  [fetchRequest setFetchLimit:limit];
  [fetchRequest setFetchOffset:offset];
  return fetchRequest;
}

@end

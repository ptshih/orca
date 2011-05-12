//
//  Snap+Serialize.m
//  Scrapboard
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Snap+Serialize.h"


@implementation Snap (Serialize)

+ (Snap *)addSnapWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Snap *newSnap = [NSEntityDescription insertNewObjectForEntityForName:@"Snap" inManagedObjectContext:context];
    
    // Required
    newSnap.id = [dictionary valueForKey:@"id"];
    newSnap.albumId = [dictionary valueForKey:@"album_id"];
    newSnap.userId = [dictionary valueForKey:@"user_id"];
    newSnap.userName = [dictionary valueForKey:@"user_name"];
    newSnap.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
    newSnap.mediaType = [dictionary valueForKey:@"media_type"];
    newSnap.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // These might be null
    newSnap.message = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"message"] : nil;
    newSnap.photoUrl = [dictionary valueForKey:@"photo_url"] ? [dictionary valueForKey:@"photo_url"] : nil;
    newSnap.videoUrl = [dictionary valueForKey:@"video_url"] ? [dictionary valueForKey:@"video_url"] : nil;
    
    newSnap.isLiked = [dictionary valueForKey:@"is_liked"] ? [dictionary valueForKey:@"is_liked"] : [NSNumber numberWithBool:NO];

    return newSnap;
  } else {
    return nil;
  }
}

- (Snap *)updateSnapWithDictionary:(NSDictionary *)dictionary {  
  // Required
  self.id = [dictionary valueForKey:@"id"];
  self.albumId = [dictionary valueForKey:@"album_id"];
  self.userId = [dictionary valueForKey:@"user_id"];
  self.userName = [dictionary valueForKey:@"user_name"];
  self.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
  self.mediaType = [dictionary valueForKey:@"media_type"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  
  // These might be null
  self.message = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"message"] : nil;
  self.photoUrl = [dictionary valueForKey:@"photo_url"] ? [dictionary valueForKey:@"photo_url"] : nil;
  self.videoUrl = [dictionary valueForKey:@"video_url"] ? [dictionary valueForKey:@"video_url"] : nil;
  
  self.isLiked = [dictionary valueForKey:@"is_liked"] ? [dictionary valueForKey:@"is_liked"] : [NSNumber numberWithBool:NO];

  
  return self;
}

@end

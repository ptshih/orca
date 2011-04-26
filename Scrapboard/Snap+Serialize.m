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
    newSnap.type = [dictionary valueForKey:@"type"];
    newSnap.userId = [dictionary valueForKey:@"user_id"];
    newSnap.userName = [dictionary valueForKey:@"user_name"];
    newSnap.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
    newSnap.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // These might be null
    newSnap.isLiked = [dictionary valueForKey:@"is_liked"] ? [dictionary valueForKey:@"is_liked"] : [NSNumber numberWithBool:NO];
    newSnap.likes = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"likes"] : nil;
    newSnap.message = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"message"] : nil;
    newSnap.photoFileName = [dictionary valueForKey:@"photo_file_name"] ? [dictionary valueForKey:@"photo_file_name"] : nil;
    newSnap.videoFileName = [dictionary valueForKey:@"video_file_name"] ? [dictionary valueForKey:@"video_file_name"] : nil;

    return newSnap;
  } else {
    return nil;
  }
}

- (Snap *)updateSnapWithDictionary:(NSDictionary *)dictionary {  
  // Required
  self.id = [dictionary valueForKey:@"id"];
  self.albumId = [dictionary valueForKey:@"album_id"];
  self.type = [dictionary valueForKey:@"type"];
  self.userId = [dictionary valueForKey:@"user_id"];
  self.userName = [dictionary valueForKey:@"user_name"];
  self.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  
  // These might be null
  self.isLiked = [dictionary valueForKey:@"is_liked"] ? [dictionary valueForKey:@"is_liked"] : [NSNumber numberWithBool:NO];
  self.likes = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"likes"] : nil;
  self.message = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"message"] : nil;
  self.photoFileName = [dictionary valueForKey:@"photo_file_name"] ? [dictionary valueForKey:@"photo_file_name"] : nil;
  self.videoFileName = [dictionary valueForKey:@"video_file_name"] ? [dictionary valueForKey:@"video_file_name"] : nil;
  
  return self;
}

@end

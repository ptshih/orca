//
//  Snap+Serialize.m
//  PhotoFeed
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
    newSnap.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // Photo
    newSnap.photoUrl = [dictionary valueForKey:@"photo_url"] ? [dictionary valueForKey:@"photo_url"] : nil;
    
    // Counts
    newSnap.commentCount = [dictionary valueForKey:@"comment_count"];
    newSnap.likeCount = [dictionary valueForKey:@"like_count"];
    
    // These might be null
    newSnap.caption = [dictionary valueForKey:@"caption"] ? [dictionary valueForKey:@"message"] : nil;
    
    // Is Liked Flag
    newSnap.isLiked = [dictionary valueForKey:@"is_liked"] ? [dictionary valueForKey:@"is_liked"] : [NSNumber numberWithBool:NO];
    
    // Lat/Lng
    newSnap.lat = [dictionary valueForKey:@"lat"];
    newSnap.lng = [dictionary valueForKey:@"lng"];
    

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
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  
  // Photo
  self.photoUrl = [dictionary valueForKey:@"photo_url"] ? [dictionary valueForKey:@"photo_url"] : nil;
  
  // Counts
  self.commentCount = [dictionary valueForKey:@"comment_count"];
  self.likeCount = [dictionary valueForKey:@"like_count"];
  
  // These might be null
  self.caption = [dictionary valueForKey:@"caption"] ? [dictionary valueForKey:@"message"] : nil;
  
  // Is Liked Flag
  self.isLiked = [dictionary valueForKey:@"is_liked"] ? [dictionary valueForKey:@"is_liked"] : [NSNumber numberWithBool:NO];
  
  // Lat/Lng
  self.lat = [dictionary valueForKey:@"lat"];
  self.lng = [dictionary valueForKey:@"lng"];
  
  return self;
}

@end

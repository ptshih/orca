//
//  Album+Serialize.m
//  Scrapboard
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Album+Serialize.h"

@implementation Album (Serialize)

- (NSString *)daysAgo {
  NSInteger day = 24 * 60 * 60;
  
  NSInteger delta = [self.timestamp timeIntervalSinceNow];
  delta *= -1;
  
  if (delta < 1 * day) {
    return @"Happening Now";
  } else {
    return [NSString stringWithFormat:@"%d days ago", delta / day];
  }
}

+ (Album *)addAlbumWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Album *newAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
    
    // Required
    newAlbum.id = [dictionary valueForKey:@"id"];
    newAlbum.name = [dictionary valueForKey:@"name"];
    newAlbum.userId = [dictionary valueForKey:@"user_id"];
    newAlbum.userName = [dictionary valueForKey:@"user_name"];
    newAlbum.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
    newAlbum.mediaType = [dictionary valueForKey:@"media_type"];
    newAlbum.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // Counts
    newAlbum.photoCount = [dictionary valueForKey:@"photo_count"];
    newAlbum.videoCount = [dictionary valueForKey:@"video_count"];
    newAlbum.commentCount = [dictionary valueForKey:@"comment_count"];
    newAlbum.likeCount = [dictionary valueForKey:@"like_count"];
    
    // These might be null
    newAlbum.message = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"message"] : nil;
    newAlbum.photoUrl = [dictionary valueForKey:@"photo_url"] ? [dictionary valueForKey:@"photo_url"] : nil;
    newAlbum.videoUrl = [dictionary valueForKey:@"video_url"] ? [dictionary valueForKey:@"video_url"] : nil;
    
    newAlbum.isFollowed = [dictionary valueForKey:@"is_followed"] ? [dictionary valueForKey:@"is_followed"] : [NSNumber numberWithBool:NO];
    
    return newAlbum;
  } else {
    return nil;
  }
}

- (Album *)updateAlbumWithDictionary:(NSDictionary *)dictionary {
  // Is Followed
  if ([dictionary valueForKey:@"is_followed"]) {
    self.isFollowed = [dictionary valueForKey:@"is_followed"];
  }
  
  // Check if this was place has actually changed
//  if ([self.timestamp isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]]]) {
//    return self;
//  }
  
  // Required
  self.id = [dictionary valueForKey:@"id"];
  self.name = [dictionary valueForKey:@"name"];
  self.userId = [dictionary valueForKey:@"user_id"];
  self.userName = [dictionary valueForKey:@"user_name"];
  self.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
  self.mediaType = [dictionary valueForKey:@"media_type"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  
  // Counts
  self.photoCount = [dictionary valueForKey:@"photo_count"];
  self.videoCount = [dictionary valueForKey:@"video_count"];
  self.commentCount = [dictionary valueForKey:@"comment_count"];
  self.likeCount = [dictionary valueForKey:@"like_count"];
  
  // These might be null
  self.message = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"message"] : nil;
  self.photoUrl = [dictionary valueForKey:@"photo_url"] ? [dictionary valueForKey:@"photo_url"] : nil;
  self.videoUrl = [dictionary valueForKey:@"video_url"] ? [dictionary valueForKey:@"video_url"] : nil;
  
  // Is Read
  self.isRead = [NSNumber numberWithBool:NO];
  
  return self;
}

@end

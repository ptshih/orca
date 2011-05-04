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
    newAlbum.message = [dictionary valueForKey:@"message"];
    newAlbum.photoUrl = [dictionary valueForKey:@"photo_url"];
    newAlbum.type = [dictionary valueForKey:@"type"];
    newAlbum.photoCount = [dictionary valueForKey:@"photo_count"];
    newAlbum.commentCount = [dictionary valueForKey:@"comment_count"];
    newAlbum.likeCount = [dictionary valueForKey:@"like_count"];
    newAlbum.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // These might be null
    newAlbum.isFollowed = [dictionary valueForKey:@"is_followed"] ? [dictionary valueForKey:@"is_followed"] : [NSNumber numberWithBool:NO];
    
    return newAlbum;
  } else {
    return nil;
  }
}

- (Album *)updateAlbumWithDictionary:(NSDictionary *)dictionary {
  if ([dictionary valueForKey:@"is_followed"]) {
    self.isFollowed = [dictionary valueForKey:@"is_followed"];
  }
  
  // Check if this was place has actually changed
  if ([self.timestamp isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]]]) {
    return self;
  }
  
  // Required
  self.id = [dictionary valueForKey:@"id"];
  self.name = [dictionary valueForKey:@"name"];
  self.userId = [dictionary valueForKey:@"user_id"];
  self.userName = [dictionary valueForKey:@"user_name"];
  self.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
  self.message = [dictionary valueForKey:@"message"];
  self.photoUrl = [dictionary valueForKey:@"photo_url"];
  self.type = [dictionary valueForKey:@"type"];
  self.photoCount = [dictionary valueForKey:@"photo_count"];
  self.commentCount = [dictionary valueForKey:@"comment_count"];
  self.likeCount = [dictionary valueForKey:@"like_count"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  
  // Is Read
  self.isRead = [NSNumber numberWithBool:NO];
  
  return self;
}

@end

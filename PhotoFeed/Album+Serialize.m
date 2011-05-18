//
//  Album+Serialize.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Album+Serialize.h"
#import "NSDate+Util.h"

@implementation Album (Serialize)

- (NSString *)daysAgo {
  NSInteger day = 24 * 60 * 60;
  
  NSInteger delta = [self.timestamp timeIntervalSinceNow];
  delta *= -1;
  
  if (delta < 1 * day) {
    return @"Today";
  } else {
    return [NSString stringWithFormat:@"%d days ago", delta / day];
  }
}

+ (Album *)addAlbumWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Album *newAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
    
    // Basic
    newAlbum.id = [dictionary valueForKey:@"id"];
    newAlbum.name = [dictionary valueForKey:@"name"];
    newAlbum.type = [dictionary valueForKey:@"type"];
    
    // Can-be-empty
    newAlbum.coverPhoto = [dictionary valueForKey:@"cover_photo"] ? [dictionary valueForKey:@"cover_photo"] : nil;
    newAlbum.caption = [dictionary valueForKey:@"description"] ? [dictionary valueForKey:@"description"] : nil;
    newAlbum.location = [dictionary valueForKey:@"location"] ? [dictionary valueForKey:@"location"] : nil;
    
    // Counts
    newAlbum.count = [dictionary valueForKey:@"count"];
    
    // Author/From
    NSDictionary *from = [dictionary valueForKey:@"from"];
    newAlbum.fromId = [from valueForKey:@"id"];
    newAlbum.fromName = [from valueForKey:@"name"];

    // Timestamp
    newAlbum.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"updated_time"]];
    
    return newAlbum;
  } else {
    return nil;
  }
}

- (Album *)updateAlbumWithDictionary:(NSDictionary *)dictionary {
  // Check if this was place has actually changed
//  if ([self.timestamp isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]]]) {
//    return self;
//  }
  
  // Basic
  self.id = [dictionary valueForKey:@"id"];
  self.name = [dictionary valueForKey:@"name"];
  self.type = [dictionary valueForKey:@"type"];
  
  // Can-be-empty
  self.coverPhoto = [dictionary valueForKey:@"cover_photo"] ? [dictionary valueForKey:@"cover_photo"] : nil;
  self.caption = [dictionary valueForKey:@"description"] ? [dictionary valueForKey:@"description"] : nil;
  self.location = [dictionary valueForKey:@"location"] ? [dictionary valueForKey:@"location"] : nil;
  
  // Counts
  self.count = [dictionary valueForKey:@"count"];
  
  // Author/From
  NSDictionary *from = [dictionary valueForKey:@"from"];
  self.fromId = [from valueForKey:@"id"];
  self.fromName = [from valueForKey:@"name"];
  
  // Timestamp
  self.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"updated_time"]];
  
  return self;
}

@end

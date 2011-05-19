//
//  Album+Serialize.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Album+Serialize.h"
#import "NSDate+Util.h"
#import "NSDate+Helper.h"

@implementation Album (Serialize)

#pragma mark -
#pragma mark Transient Properties
- (NSString *)daysAgo {
  //  NSInteger day = 24 * 60 * 60;
  //  
  //  NSInteger delta = [self.timestamp timeIntervalSinceNow];
  //  delta *= -1;
  //  
  //  if (delta < 1 * day) {
  //    return @"Today";
  //  } else {
  //    return [NSString stringWithFormat:@"%d days ago", delta / day];
  //  }
  
  //  return [self.timestamp stringDaysAgoAgainstMidnight:YES];
  return [NSDate stringForDisplayFromDate:self.timestamp];
}

#pragma mark -
#pragma mark Create/Update
+ (Album *)addAlbumWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Album *newAlbum = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
    
    // Basic
    newAlbum.id = [dictionary valueForKey:@"id"];
    newAlbum.name = [dictionary valueForKey:@"name"];
    newAlbum.type = [dictionary valueForKey:@"type"];
    
    // Can-be-empty
    newAlbum.coverPhoto = [dictionary valueForKey:@"cover_photo"] ? [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [dictionary valueForKey:@"cover_photo"]] : nil;
    
#warning some albums have no cover photo
    if (![dictionary valueForKey:@"cover_photo"]) {
      NSLog(@"uh oh, no cover photo");
    }
    
    newAlbum.caption = [dictionary valueForKey:@"description"] ? [dictionary valueForKey:@"description"] : nil;
    newAlbum.location = [dictionary valueForKey:@"location"] ? [dictionary valueForKey:@"location"] : nil;
    
    // Counts
    newAlbum.count = [dictionary valueForKey:@"count"];
    
    // Author/From
    NSDictionary *from = [dictionary valueForKey:@"from"];
    newAlbum.fromId = [from valueForKey:@"id"];
    newAlbum.fromName = [from valueForKey:@"name"];
    
    // Timestamp
    if ([dictionary valueForKey:@"updated_time"]) {
      newAlbum.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"updated_time"]];
    } else if ([dictionary valueForKey:@"created_time"]) {
      newAlbum.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"created_time"]];
    } else {
      newAlbum.timestamp = [NSDate distantPast];
    }
    
    return newAlbum;
  } else {
    return nil;
  }
}

- (Album *)updateAlbumWithDictionary:(NSDictionary *)dictionary {
  if (dictionary) {    
    
    // Check to see if this album has actually changed
    NSDate *newDate = nil;
    if ([dictionary valueForKey:@"updated_time"]) {
      newDate = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"updated_time"]];
    } else if ([dictionary valueForKey:@"created_time"]) {
      newDate = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"created_time"]];
    } else {
      newDate = [NSDate distantPast];
    }
    
    if ([self.timestamp isEqualToDate:newDate]) return self;
    
    // Comparing photo count is much more efficient than parsing a date
    // Doesn't work, some albums have nil count
    //    NSNumber *newPhotoCount = [dictionary valueForKey:@"count"];
    //    if ([newPhotoCount isEqualToNumber:self.count]) return self;
    
    // If dates are not the same, then perform an update
    
    // Basic
    self.id = [dictionary valueForKey:@"id"];
    self.name = [dictionary valueForKey:@"name"];
    self.type = [dictionary valueForKey:@"type"];
    
    // Can-be-empty
    self.coverPhoto = [dictionary valueForKey:@"cover_photo"] ? [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", [dictionary valueForKey:@"cover_photo"]] : nil;
    self.caption = [dictionary valueForKey:@"description"] ? [dictionary valueForKey:@"description"] : nil;
    self.location = [dictionary valueForKey:@"location"] ? [dictionary valueForKey:@"location"] : nil;
    
    // Counts
    self.count = [dictionary valueForKey:@"count"];
    
    // Author/From
    NSDictionary *from = [dictionary valueForKey:@"from"];
    self.fromId = [from valueForKey:@"id"];
    self.fromName = [from valueForKey:@"name"];
    
    // Timestamp
    if ([dictionary valueForKey:@"updated_time"]) {
      self.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"updated_time"]];
    } else if ([dictionary valueForKey:@"created_time"]) {
      self.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"created_time"]];
    } else {
      self.timestamp = [NSDate distantPast];
    }
    
    return self;
  } else {
    return nil;
  }
}

@end

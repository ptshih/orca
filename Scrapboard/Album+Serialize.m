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
    return @"Today";
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
    newAlbum.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // Counts
    newAlbum.photoCount = [dictionary valueForKey:@"photo_count"];
    
    // Participants
    newAlbum.participants = [dictionary valueForKey:@"participants"];
    
    // Photos
    // This is provided as an array of photoUrls
    // We're gonna put them into a comma-separated string
    NSArray *photoUrlArray = [dictionary valueForKey:@"photo_urls"];
    newAlbum.photoUrls = [photoUrlArray componentsJoinedByString:@","];
    
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
  
  // Required
  self.id = [dictionary valueForKey:@"id"];
  self.name = [dictionary valueForKey:@"name"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  
  // Counts
  self.photoCount = [dictionary valueForKey:@"photo_count"];
  
  // Participants
  self.participants = [dictionary valueForKey:@"participants"];
  
  // Photos
  // This is provided as an array of photoUrls
  // We're gonna put them into a comma-separated string
  NSArray *photoUrlArray = [dictionary valueForKey:@"photo_urls"];
  self.photoUrls = [photoUrlArray componentsJoinedByString:@","];
  
  return self;
}

@end

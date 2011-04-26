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
    newAlbum.tag = [dictionary valueForKey:@"tag"];
    newAlbum.name = [dictionary valueForKey:@"name"];
    newAlbum.userId = [dictionary valueForKey:@"user_id"];
    newAlbum.userName = [dictionary valueForKey:@"user_name"];
    newAlbum.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
    newAlbum.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // These might be null
    newAlbum.isFollowed = [dictionary valueForKey:@"is_followed"] ? [dictionary valueForKey:@"is_followed"] : [NSNumber numberWithBool:NO];
    newAlbum.lastActivity = [dictionary valueForKey:@"last_activity"] ? [dictionary valueForKey:@"last_activity"] : nil;
    
    // Participants Summary
    NSMutableArray *participantIds = [NSMutableArray array];
    NSMutableArray *participantFacebookIds = [NSMutableArray array];
    NSMutableArray *participantFirstNames = [NSMutableArray array];
    NSMutableArray *participantFullNames = [NSMutableArray array];
    NSArray *participants = [dictionary valueForKey:@"participants"];
    for (NSDictionary *participant in participants) {
      [participantIds addObject:[participant valueForKey:@"id"]];
      [participantFacebookIds addObject:[participant valueForKey:@"facebook_id"]];
      [participantFirstNames addObject:[participant valueForKey:@"first_name"]];
      [participantFullNames addObject:[participant valueForKey:@"name"]];
    }
    
    newAlbum.participantIds = [participantIds componentsJoinedByString:@","];
    newAlbum.participantFacebookIds = [participantFacebookIds componentsJoinedByString:@","];
    newAlbum.participantFirstNames = [participantFirstNames componentsJoinedByString:@", "];
    newAlbum.participantFullNames = [participantFullNames componentsJoinedByString:@", "];
    
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
  
  //  // Required
  self.id = [dictionary valueForKey:@"id"];
  self.tag = [dictionary valueForKey:@"tag"];
  self.name = [dictionary valueForKey:@"name"];
  self.userId = [dictionary valueForKey:@"user_id"];
  self.userName = [dictionary valueForKey:@"user_name"];
  self.userPictureUrl = [dictionary valueForKey:@"user_picture_url"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  
  // These might be null
  self.lastActivity = [dictionary valueForKey:@"last_activity"] ? [dictionary valueForKey:@"last_activity"] : nil;
  
  // Participants Summary
  NSMutableArray *participantIds = [NSMutableArray array];
  NSMutableArray *participantFacebookIds = [NSMutableArray array];
  NSMutableArray *participantFirstNames = [NSMutableArray array];
  NSMutableArray *participantFullNames = [NSMutableArray array];
  NSArray *participants = [dictionary valueForKey:@"participants"];
  for (NSDictionary *participant in participants) {
    [participantIds addObject:[participant valueForKey:@"id"]];
    [participantFacebookIds addObject:[participant valueForKey:@"facebook_id"]];
    [participantFirstNames addObject:[participant valueForKey:@"first_name"]];
    [participantFullNames addObject:[participant valueForKey:@"name"]];
  }
  
  self.participantIds = [participantIds componentsJoinedByString:@","];
  self.participantFacebookIds = [participantFacebookIds componentsJoinedByString:@","];
  self.participantFirstNames = [participantFirstNames componentsJoinedByString:@", "];
  self.participantFullNames = [participantFullNames componentsJoinedByString:@", "];
  
  // Is Read
  self.isRead = [NSNumber numberWithBool:NO];
  
  return self;
}

@end

//
//  Place+Serialize.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Place+Serialize.h"

@implementation Place (Serialize)

+ (Place *)addPlaceWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Place *newPlace = [NSEntityDescription insertNewObjectForEntityForName:@"Place" inManagedObjectContext:context];
    
    newPlace.id = [dictionary valueForKey:@"id"];
    newPlace.placeId = [dictionary valueForKey:@"place_id"];
    newPlace.name = [dictionary valueForKey:@"name"];
    newPlace.hasPhoto = [dictionary valueForKey:@"has_photo"];
    newPlace.hasVideo = [dictionary valueForKey:@"has_video"];
    newPlace.authorId = [dictionary valueForKey:@"author_id"];
    newPlace.authorName = [dictionary valueForKey:@"author_name"];
    
    // These might be null
    newPlace.pictureUrl = [dictionary valueForKey:@"picture_url"] ? [dictionary valueForKey:@"picture_url"] : nil;
    newPlace.activityCount = [dictionary valueForKey:@"activity_count"] ? [dictionary valueForKey:@"activity_count"] : @"0";
    newPlace.comment = [dictionary valueForKey:@"comment"] ? [dictionary valueForKey:@"comment"] : nil;
    newPlace.kupoType = [dictionary valueForKey:@"kupo_type"] ? [dictionary valueForKey:@"kupo_type"] : nil;
    
    NSString *city = [dictionary valueForKey:@"place_city"] ? [dictionary valueForKey:@"place_city"] : nil;
    NSString *state = [dictionary valueForKey:@"place_state"] ? [dictionary valueForKey:@"place_state"] : nil;
    if (city && state) {
      newPlace.address = [NSString stringWithFormat:@"%@, %@", city, state];
    }
    
    // Friends Summary
    NSMutableArray *friendIds = [NSMutableArray array];
    NSMutableArray *friendFirstNames = [NSMutableArray array];
    NSMutableArray *friendFullNames = [NSMutableArray array];
    NSArray *friendList = [dictionary valueForKey:@"friend_list"];
    for (NSDictionary *friend in friendList) {
      [friendIds addObject:[friend valueForKey:@"facebook_id"]];
      [friendFirstNames addObject:[friend valueForKey:@"first_name"]];
      [friendFullNames addObject:[friend valueForKey:@"full_name"]];
    }
    
    newPlace.friendIds = [friendIds componentsJoinedByString:@", "];
    newPlace.friendFirstNames = [friendFirstNames componentsJoinedByString:@", "];
    newPlace.friendFullNames = [friendFullNames componentsJoinedByString:@", "];
    
    newPlace.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    return newPlace;
  } else {
    return nil;
  }
}

- (Place *)updatePlaceWithDictionary:(NSDictionary *)dictionary {
  // Check if this was place has actually changed
  if ([self.timestamp isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]]]) {
    return self;
  }
  
  self.placeId = [dictionary valueForKey:@"place_id"];
  self.name = [dictionary valueForKey:@"name"];
  self.hasPhoto = [dictionary valueForKey:@"has_photo"];
  self.hasVideo = [dictionary valueForKey:@"has_video"];
  self.authorId = [dictionary valueForKey:@"author_id"];
  self.authorName = [dictionary valueForKey:@"author_name"];
  
  self.pictureUrl = [dictionary valueForKey:@"picture_url"];
  self.activityCount = [dictionary valueForKey:@"activity_count"];
  self.comment = [dictionary valueForKey:@"comment"];
  self.kupoType = [dictionary valueForKey:@"kupo_type"] ? [dictionary valueForKey:@"kupo_type"] : nil;
  
  NSString *city = [dictionary valueForKey:@"place_city"] ? [dictionary valueForKey:@"place_city"] : nil;
  NSString *state = [dictionary valueForKey:@"place_state"] ? [dictionary valueForKey:@"place_state"] : nil;
  if (city && state) {
    self.address = [NSString stringWithFormat:@"%@, %@", city, state];
  }

  // Friends Summary
  NSMutableArray *friendIds = [NSMutableArray array];
  NSMutableArray *friendFirstNames = [NSMutableArray array];
  NSMutableArray *friendFullNames = [NSMutableArray array];
  NSArray *friendList = [dictionary valueForKey:@"friend_list"];
  for (NSDictionary *friend in friendList) {
    [friendIds addObject:[friend valueForKey:@"facebook_id"]];
    [friendFirstNames addObject:[friend valueForKey:@"first_name"]];
    [friendFullNames addObject:[friend valueForKey:@"full_name"]];
  }
  
  self.friendIds = [friendIds componentsJoinedByString:@", "];
  self.friendFirstNames = [friendFirstNames componentsJoinedByString:@", "];
  self.friendFullNames = [friendFullNames componentsJoinedByString:@", "];
  
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  self.isRead = [NSNumber numberWithBool:NO];
  
  return self;
}

@end

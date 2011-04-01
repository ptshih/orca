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
    
    // These might be null
    newPlace.pictureUrl = [dictionary valueForKey:@"picture_url"] ? [dictionary valueForKey:@"picture_url"] : nil;
    newPlace.activityCount = [dictionary valueForKey:@"activity_count"] ? [dictionary valueForKey:@"activity_count"] : @"0";
    newPlace.comment = [dictionary valueForKey:@"comment"] ? [dictionary valueForKey:@"comment"] : nil;
    newPlace.type = [dictionary valueForKey:@"type"] ? [dictionary valueForKey:@"type"] : nil;
    
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

- (void)updatePlaceWithDictionary:(NSDictionary *)dictionary {
  self.name = [dictionary valueForKey:@"name"];
  self.placeId = [dictionary valueForKey:@"place_id"];
  self.hasPhoto = [dictionary valueForKey:@"has_photo"];
  self.pictureUrl = [dictionary valueForKey:@"picture_url"];
  self.activityCount = [dictionary valueForKey:@"activity_count"];
  self.comment = [dictionary valueForKey:@"comment"];
  self.type = [dictionary valueForKey:@"type"];

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
}

@end

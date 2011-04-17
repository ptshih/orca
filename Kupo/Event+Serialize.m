//
//  Event+Serialize.m
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Event+Serialize.h"

@implementation Event (Serialize)

+ (Event *)addEventWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Event *newEvent = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];

    // Required
    newEvent.id = [dictionary valueForKey:@"id"];
    newEvent.tag = [dictionary valueForKey:@"tag"];
    newEvent.name = [dictionary valueForKey:@"name"];
    newEvent.authorId = [dictionary valueForKey:@"author_id"];
    newEvent.authorFacebookId = [dictionary valueForKey:@"author_facebook_id"];
    newEvent.authorName = [dictionary valueForKey:@"author_name"];
    newEvent.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // These might be null
    newEvent.lastActivity = [dictionary valueForKey:@"last_activity"] ? [dictionary valueForKey:@"last_activity"] : nil;
    
    // Friends Summary
    NSMutableArray *friendIds = [NSMutableArray array];
    NSMutableArray *friendFirstNames = [NSMutableArray array];
    NSMutableArray *friendFullNames = [NSMutableArray array];
    NSArray *friendList = [dictionary valueForKey:@"friend_list"];
    for (NSDictionary *friend in friendList) {
      [friendIds addObject:[friend valueForKey:@"facebook_id"]];
      [friendFirstNames addObject:[friend valueForKey:@"first_name"]];
      [friendFullNames addObject:[friend valueForKey:@"name"]];
    }
    
    newEvent.friendIds = [friendIds componentsJoinedByString:@","];
    newEvent.friendFirstNames = [friendFirstNames componentsJoinedByString:@", "];
    newEvent.friendFullNames = [friendFullNames componentsJoinedByString:@", "];
    
    return newEvent;
  } else {
    return nil;
  }
}

- (Event *)updateEventWithDictionary:(NSDictionary *)dictionary {
  // Check if this was place has actually changed
  if ([self.timestamp isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]]]) {
    return self;
  }
  
  // Required
  self.id = [dictionary valueForKey:@"id"];
  self.tag = [dictionary valueForKey:@"tag"];
  self.name = [dictionary valueForKey:@"name"];
  self.authorId = [dictionary valueForKey:@"author_id"];
  self.authorFacebookId = [dictionary valueForKey:@"author_facebook_id"];
  self.authorName = [dictionary valueForKey:@"author_name"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  
  // These might be null
  self.lastActivity = [dictionary valueForKey:@"last_activity"] ? [dictionary valueForKey:@"last_activity"] : nil;
  

  // Friends Summary
  NSMutableArray *friendIds = [NSMutableArray array];
  NSMutableArray *friendFirstNames = [NSMutableArray array];
  NSMutableArray *friendFullNames = [NSMutableArray array];
  NSArray *friendList = [dictionary valueForKey:@"friend_list"];
  for (NSDictionary *friend in friendList) {
    [friendIds addObject:[friend valueForKey:@"facebook_id"]];
    [friendFirstNames addObject:[friend valueForKey:@"first_name"]];
    [friendFullNames addObject:[friend valueForKey:@"name"]];
  }
  
  self.friendIds = [friendIds componentsJoinedByString:@","];
  self.friendFirstNames = [friendFirstNames componentsJoinedByString:@", "];
  self.friendFullNames = [friendFullNames componentsJoinedByString:@", "];
  
  // Is Read
  self.isRead = [NSNumber numberWithBool:NO];
  
  return self;
}

@end

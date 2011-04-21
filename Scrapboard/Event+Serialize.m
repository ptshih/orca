//
//  Event+Serialize.m
//  Scrapboard
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
    
    newEvent.participantIds = [participantIds componentsJoinedByString:@","];
    newEvent.participantFacebookIds = [participantFacebookIds componentsJoinedByString:@","];
    newEvent.participantFirstNames = [participantFirstNames componentsJoinedByString:@", "];
    newEvent.participantFullNames = [participantFullNames componentsJoinedByString:@", "];
    
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
  
//  // Required
//  self.id = [dictionary valueForKey:@"id"];
//  self.tag = [dictionary valueForKey:@"tag"];
//  self.name = [dictionary valueForKey:@"name"];
//  self.authorId = [dictionary valueForKey:@"author_id"];
//  self.authorFacebookId = [dictionary valueForKey:@"author_facebook_id"];
//  self.authorName = [dictionary valueForKey:@"author_name"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
//  
//  // These might be null
//  self.lastActivity = [dictionary valueForKey:@"last_activity"] ? [dictionary valueForKey:@"last_activity"] : nil;
//  
//  // Participants Summary
//  NSMutableArray *participantIds = [NSMutableArray array];
//  NSMutableArray *participantFacebookIds = [NSMutableArray array];
//  NSMutableArray *participantFirstNames = [NSMutableArray array];
//  NSMutableArray *participantFullNames = [NSMutableArray array];
//  NSArray *participants = [dictionary valueForKey:@"participants"];
//  for (NSDictionary *participant in participants) {
//    [participantIds addObject:[participant valueForKey:@"id"]];
//    [participantFacebookIds addObject:[participant valueForKey:@"facebook_id"]];
//    [participantFirstNames addObject:[participant valueForKey:@"first_name"]];
//    [participantFullNames addObject:[participant valueForKey:@"name"]];
//  }
//  
//  self.participantIds = [participantIds componentsJoinedByString:@","];
//  self.participantFacebookIds = [participantFacebookIds componentsJoinedByString:@","];
//  self.participantFirstNames = [participantFirstNames componentsJoinedByString:@", "];
//  self.participantFullNames = [participantFullNames componentsJoinedByString:@", "];
//  
//  // Is Read
//  self.isRead = [NSNumber numberWithBool:NO];
//  
  return self;
}

@end

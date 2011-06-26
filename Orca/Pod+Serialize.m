//
//  Pod+Serialize.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Pod+Serialize.h"
#import "NSDate+Helper.h"
#import "NSObject+SML.h"
#import "NSString+SML.h"

@implementation Pod (Serialize)

#pragma mark -
#pragma mark Transient Properties
- (NSString *)daysAgo {
  return [NSDate stringForDisplayFromDate:self.timestamp];
}

+ (Pod *)addPodWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    // Create new pod entity
    Pod *newPod = [NSEntityDescription insertNewObjectForEntityForName:@"Pod" inManagedObjectContext:context];

    newPod.id = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"id"]];
    newPod.sequence = [[dictionary valueForKey:@"sequence"] notNil] ? [dictionary valueForKey:@"sequence"] : nil;
    newPod.name = [dictionary valueForKey:@"name"];
    newPod.fromId = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"from_id"]];
    newPod.fromName = [dictionary valueForKey:@"from_name"];
    newPod.fromPictureUrl = [dictionary valueForKey:@"from_picture_url"];
    newPod.participants = [[dictionary valueForKey:@"participants"] notNil] ? [dictionary valueForKey:@"participants"] : nil;
    newPod.metadata = [[dictionary valueForKey:@"metadata"] notNil] ? [dictionary valueForKey:@"metadata"] : nil;
    newPod.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    return newPod;
  } else {
    // Invalid Input, Ignore Serialization
    return nil;
  }
}

- (Pod *)updatePodWithDictionary:(NSDictionary *)dictionary {
  if (dictionary) {
    // First check to make sure this pod actually changed
//    NSDate *existingTimestamp = self.timestamp;
//    NSDate *newTimestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    // Compare last known sequence local <-> remote    
//    if (![existingTimestamp isEqualToDate:newTimestamp]) {
    NSString *newSequence = [[dictionary valueForKey:@"sequence"] notNil] ? [dictionary valueForKey:@"sequence"] : nil;
    if (newSequence && ![self.sequence isEqualToString:newSequence]) {
      // timestamp changed, update pod info
      self.unread = [NSNumber numberWithBool:YES]; // set unread
      
      // Update properties that can change
      self.sequence = [[dictionary valueForKey:@"sequence"] notNil] ? [dictionary valueForKey:@"sequence"] : nil;
      self.name = [dictionary valueForKey:@"name"];
      self.fromId = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"from_id"]];
      self.fromName = [dictionary valueForKey:@"from_name"];
      self.fromPictureUrl = [dictionary valueForKey:@"from_picture_url"];
      self.participants = [[dictionary valueForKey:@"participants"] notNil] ? [dictionary valueForKey:@"participants"] : nil;
      self.metadata = [[dictionary valueForKey:@"metadata"] notNil] ? [dictionary valueForKey:@"metadata"] : nil;;
      self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
      
      return self;
    } else {
      return self;
    }
  } else {
    // Invalid Input, Ignore Serialization
    return self;
  }
}

@end

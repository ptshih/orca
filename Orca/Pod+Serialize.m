//
//  Pod+Serialize.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Pod+Serialize.h"
#import "NSObject+ConvenienceMethods.h"
#import "NSString+ConvenienceMethods.h"
#import "NSDate+Helper.h"

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
    newPod.fromId = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"fromId"]];
    newPod.fromName = [dictionary valueForKey:@"fromName"];
    newPod.fromPictureUrl = [dictionary valueForKey:@"fromPictureUrl"];
    newPod.participants = [[dictionary valueForKey:@"participants"] notNil] ? [dictionary valueForKey:@"participants"] : nil;
    newPod.message = [[dictionary valueForKey:@"message"] notNil] ? [dictionary valueForKey:@"message"] : nil;
    newPod.lat = [[dictionary valueForKey:@"lat"] notNil] ? [dictionary valueForKey:@"lat"] : nil;
    newPod.lng = [[dictionary valueForKey:@"lng"] notNil] ? [dictionary valueForKey:@"lng"] : nil;
    //    newPod.location = [dictionary valueForKey:@"location"];
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
      self.name = [dictionary valueForKey:@"name"];
      self.fromId = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"fromId"]];
      self.fromName = [dictionary valueForKey:@"fromName"];
      self.fromPictureUrl = [dictionary valueForKey:@"fromPictureUrl"];
      self.participants = [[dictionary valueForKey:@"participants"] notNil] ? [dictionary valueForKey:@"participants"] : nil;
      self.message = [[dictionary valueForKey:@"message"] notNil] ? [dictionary valueForKey:@"message"] : nil;;
      self.lat = [[dictionary valueForKey:@"lat"] notNil] ? [dictionary valueForKey:@"lat"] : nil;
      self.lng = [[dictionary valueForKey:@"lng"] notNil] ? [dictionary valueForKey:@"lng"] : nil;
      //    self.location = [dictionary valueForKey:@"location"];
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

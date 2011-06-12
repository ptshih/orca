//
//  Pod+Serialize.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Pod+Serialize.h"

@implementation Pod (Serialize)

+ (Pod *)addPodWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    // Create new pod entity
    Pod *newPod = [NSEntityDescription insertNewObjectForEntityForName:@"Pod" inManagedObjectContext:context];

    newPod.id = [dictionary valueForKey:@"id"];
    newPod.name = [dictionary valueForKey:@"name"];
    newPod.fromId = [dictionary valueForKey:@"fromId"];
    newPod.fromName = [dictionary valueForKey:@"fromName"];
    newPod.fromPictureUrl = [dictionary valueForKey:@"fromPictureUrl"];
    newPod.participants = [dictionary valueForKey:@"participants"];
    newPod.message = [dictionary valueForKey:@"message"];
    newPod.lat = [dictionary valueForKey:@"lat"] ? [dictionary valueForKey:@"lat"] : nil;
    newPod.lng = [dictionary valueForKey:@"lng"] ? [dictionary valueForKey:@"lng"] : nil;
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
    if (![self.timestamp isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]]]) {    
      // Update properties that can change
      self.name = [dictionary valueForKey:@"name"];
      self.fromId = [dictionary valueForKey:@"fromId"];
      self.fromName = [dictionary valueForKey:@"fromName"];
      self.fromPictureUrl = [dictionary valueForKey:@"fromPictureUrl"];
      self.participants = [dictionary valueForKey:@"participants"];
      self.message = [dictionary valueForKey:@"message"];
      self.lat = [dictionary valueForKey:@"lat"] ? [dictionary valueForKey:@"lat"] : nil;
      self.lng = [dictionary valueForKey:@"lng"] ? [dictionary valueForKey:@"lng"] : nil;
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

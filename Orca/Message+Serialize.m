//
//  Message+Serialize.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Message+Serialize.h"

@implementation Message (Serialize)

+ (Message *)addMessageWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    // Create new pod entity
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    
    newMessage.id = [dictionary valueForKey:@"id"];
    newMessage.podId = [dictionary valueForKey:@"podId"];
    newMessage.fromId = [dictionary valueForKey:@"fromId"];
    newMessage.fromName = [dictionary valueForKey:@"fromName"];
    newMessage.fromPictureUrl = [dictionary valueForKey:@"fromPictureUrl"];
    newMessage.message = [dictionary valueForKey:@"message"];
    newMessage.lat = [dictionary valueForKey:@"lat"] ? [dictionary valueForKey:@"lat"] : nil;
    newMessage.lng = [dictionary valueForKey:@"lng"] ? [dictionary valueForKey:@"lng"] : nil;
    //    newMessage.location = [dictionary valueForKey:@"location"];
    newMessage.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    return newMessage;
  } else {
    // Invalid Input, Ignore Serialization
    return nil;
  }
}

- (Message *)updateMessageWithDictionary:(NSDictionary *)dictionary {
  if (dictionary) {
    // First check to make sure this pod actually changed
    if (![self.timestamp isEqualToDate:[NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]]]) {    
      // Update properties that can change
      self.fromId = [dictionary valueForKey:@"fromId"];
      self.fromName = [dictionary valueForKey:@"fromName"];
      self.fromPictureUrl = [dictionary valueForKey:@"fromPictureUrl"];
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

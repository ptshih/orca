//
//  Message+Serialize.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Message+Serialize.h"
#import "NSObject+ConvenienceMethods.h"

@implementation Message (Serialize)

+ (Message *)addMessageWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    // Create new pod entity
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    
    newMessage.id = [dictionary valueForKey:@"id"];
    newMessage.podId = [dictionary valueForKey:@"podId"];
    newMessage.sequence = [dictionary valueForKey:@"sequence"];
    newMessage.fromId = [dictionary valueForKey:@"fromId"];
    newMessage.fromName = [dictionary valueForKey:@"fromName"];
    newMessage.fromPictureUrl = [dictionary valueForKey:@"fromPictureUrl"];
    newMessage.message = [dictionary valueForKey:@"message"];
    newMessage.lat = [[dictionary valueForKey:@"lat"] notNil] ? [dictionary valueForKey:@"lat"] : nil;
    newMessage.lng = [[dictionary valueForKey:@"lng"] notNil] ? [dictionary valueForKey:@"lng"] : nil;
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
    // Messages only change if there was originally no ID, and now there is
    if (!self.id) {
      self.id = [dictionary valueForKey:@"id"];
      self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    }
    return self;
  } else {
    // Invalid Input, Ignore Serialization
    return self;
  }
}

@end

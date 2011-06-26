//
//  Message+Serialize.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Message+Serialize.h"
#import "NSObject+SML.h"
#import "NSString+SML.h"

@implementation Message (Serialize)

+ (Message *)addMessageWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    // Create new pod entity
    Message *newMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:context];
    
    newMessage.id = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"id"]];
    newMessage.podId = [dictionary valueForKey:@"podId"];
    newMessage.sequence = [dictionary valueForKey:@"sequence"];
    newMessage.messageType = [[dictionary valueForKey:@"message_type"] notNil] ? [dictionary valueForKey:@"message_type"] : nil;
    newMessage.fromId = [NSString stringWithFormat:@"%@", [dictionary valueForKey:@"fromId"]];
    newMessage.fromName = [dictionary valueForKey:@"fromName"];
    newMessage.fromPictureUrl = [dictionary valueForKey:@"fromPictureUrl"];
    newMessage.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // Metadata
    newMessage.metadata = [dictionary valueForKey:@"metadata"] ? [dictionary valueForKey:@"metadata"] : nil;
        
    return newMessage;
  } else {
    // Invalid Input, Ignore Serialization
    return nil;
  }
}

- (Message *)updateMessageWithDictionary:(NSDictionary *)dictionary {
  if (dictionary) {

    NSDate *existingTimestamp = self.timestamp;
    NSDate *newTimestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    if (![existingTimestamp isEqualToDate:newTimestamp] || ![self.id notNull]) {
      // Update basic data
      self.id = [dictionary valueForKey:@"id"];
      self.messageType = [[dictionary valueForKey:@"message_type"] notNil] ? [dictionary valueForKey:@"message_type"] : nil;
      self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
      
      // Update metadata
      self.metadata = [dictionary valueForKey:@"metadata"] ? [dictionary valueForKey:@"metadata"] : nil;
    }
    return self;
  } else {
    // Invalid Input, Ignore Serialization
    return self;
  }
}

@end

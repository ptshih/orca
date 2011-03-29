//
//  Pod+Serialize.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Pod+Serialize.h"

@implementation Pod (Serialize)

+ (Pod *)addPodWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Pod *newPod = [NSEntityDescription insertNewObjectForEntityForName:@"Pod" inManagedObjectContext:context];
    
    newPod.id = [dictionary valueForKey:@"id"];
    newPod.name = [dictionary valueForKey:@"name"];
    newPod.summary = [dictionary valueForKey:@"summary"];
    newPod.pictureUrl = [dictionary valueForKey:@"picture_url"];
    newPod.checkinCount = [dictionary valueForKey:@"checkin_count"];
    newPod.commentCount = [dictionary valueForKey:@"comment_count"];
    newPod.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    return newPod;
  } else {
    return nil;
  }
}

- (void)updatePodWithDictionary:(NSDictionary *)dictionary {
  self.name = [dictionary valueForKey:@"name"];
  self.summary = [dictionary valueForKey:@"summary"];
  self.pictureUrl = [dictionary valueForKey:@"picture_url"];
  self.checkinCount = [dictionary valueForKey:@"checkin_count"];
  self.commentCount = [dictionary valueForKey:@"comment_count"];
  self.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
  self.isRead = [NSNumber numberWithBool:NO];
}

@end

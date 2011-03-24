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
    newPod.lastActivity = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"last_activity"] longLongValue]];
    
    return newPod;
  } else {
    return nil;
  }
}

@end

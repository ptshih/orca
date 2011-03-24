//
//  Feed+Serialize.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Feed+Serialize.h"


@implementation Feed (Serialize)

+ (Feed *)addFeedWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Feed *newFeed = [NSEntityDescription insertNewObjectForEntityForName:@"Feed" inManagedObjectContext:context];
    
    newFeed.id = [dictionary valueForKey:@"id"];
    newFeed.type = [dictionary valueForKey:@"type"];
    newFeed.podId = [dictionary valueForKey:@"pod_id"];
    newFeed.authorId = [dictionary valueForKey:@"author_id"];
    newFeed.authorName = [dictionary valueForKey:@"author_name"];
    newFeed.authorPictureUrl = [dictionary valueForKey:@"author_picture_url"];
    newFeed.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // Conditional
    newFeed.comment = [dictionary valueForKey:@"comment"] ? [dictionary valueForKey:@"comment"] : nil;
    newFeed.photoUrl = [dictionary valueForKey:@"photo_url"] ? [dictionary valueForKey:@"photo_url"] : nil;
    
    return newFeed;
  } else {
    return nil;
  }
}

@end

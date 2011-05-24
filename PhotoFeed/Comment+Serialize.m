//
//  Comment+Serialize.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Comment+Serialize.h"
#import "NSDate+Util.h"
#import "NSDate+Helper.h"

@implementation Comment (Serialize)

+ (Comment *)addCommentWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Comment *newComment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
    
    // Basic
    newComment.id = [dictionary valueForKey:@"id"];
    newComment.message = [dictionary valueForKey:@"message"];
    
    // Author/From
    NSDictionary *from = [dictionary valueForKey:@"from"];
    newComment.fromId = [from valueForKey:@"id"];
    newComment.fromName = [from valueForKey:@"name"];
    
    // Timestamp
    if ([dictionary valueForKey:@"created_time"]) {
      newComment.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"created_time"]];
    } else {
      newComment.timestamp = [NSDate distantPast];
    }
    
    return newComment;
  } else {
    return nil;
  }
}

@end

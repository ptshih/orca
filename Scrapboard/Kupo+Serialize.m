//
//  Scrapboard+Serialize.m
//  Scrapboard
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Kupo+Serialize.h"


@implementation Kupo (Serialize)

+ (Kupo *)addKupoWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Kupo *newKupo = [NSEntityDescription insertNewObjectForEntityForName:@"Kupo" inManagedObjectContext:context];
    
    newKupo.id = [dictionary valueForKey:@"id"];
    newKupo.eventId = [dictionary valueForKey:@"event_id"];
    newKupo.authorId = [dictionary valueForKey:@"author_id"];
    newKupo.authorFacebookId = [dictionary valueForKey:@"author_facebook_id"];
    newKupo.authorName = [dictionary valueForKey:@"author_name"];
    newKupo.hasPhoto = [dictionary valueForKey:@"has_photo"];
    newKupo.hasVideo = [dictionary valueForKey:@"has_video"];
    newKupo.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // Conditional
    newKupo.message = [dictionary valueForKey:@"message"] ? [dictionary valueForKey:@"message"] : nil;
    newKupo.photoFileName = [dictionary valueForKey:@"photo_file_name"] ? [dictionary valueForKey:@"photo_file_name"] : nil;
    newKupo.videoFileName = [dictionary valueForKey:@"video_file_name"] ? [dictionary valueForKey:@"video_file_name"] : nil;
    
    return newKupo;
  } else {
    return nil;
  }
}

@end

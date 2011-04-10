//
//  Kupo+Serialize.m
//  Kupo
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
    newKupo.placeId = [dictionary valueForKey:@"place_id"];
    newKupo.kupoType = [dictionary valueForKey:@"kupo_type"];
    newKupo.authorId = [dictionary valueForKey:@"author_id"];
    newKupo.authorName = [dictionary valueForKey:@"author_name"];
    newKupo.hasPhoto = [dictionary valueForKey:@"has_photo"];
    newKupo.hasVideo = [dictionary valueForKey:@"has_video"];
    newKupo.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // Conditional
    newKupo.appName = [dictionary valueForKey:@"app_name"] ? [dictionary valueForKey:@"app_name"] : nil;
    newKupo.comment = [dictionary valueForKey:@"comment"] ? [dictionary valueForKey:@"comment"] : nil;
    newKupo.photoFileName = [dictionary valueForKey:@"photo_file_name"] ? [dictionary valueForKey:@"photo_file_name"] : nil;
    newKupo.videoFileName = [dictionary valueForKey:@"video_file_name"] ? [dictionary valueForKey:@"video_file_name"] : nil;
    
    NSArray *friendList = [dictionary valueForKey:@"friend_list"];
    if (friendList) {
      NSMutableArray *friends = [NSMutableArray arrayWithCapacity:1];
      for (NSDictionary *friend in friendList) {
        [friends addObject:[friend valueForKey:@"full_name"]];
      }
      newKupo.tagged = [friends componentsJoinedByString:@", "];
    }
    
    return newKupo;
  } else {
    return nil;
  }
}

@end

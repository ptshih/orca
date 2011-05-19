//
//  Photo+Serialize.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Photo+Serialize.h"
#import "NSDate+Util.h"
#import "NSDate+Helper.h"

@implementation Photo (Serialize)

#pragma mark -
#pragma mark Transient Properties
- (NSString *)fromPicture {
  return [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", self.fromId];
}

#pragma mark -
#pragma mark Create/Update
+ (Photo *)addPhotoWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context {
  if (dictionary) {
    Photo *newPhoto = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
    
    // Basic
    newPhoto.id = [dictionary valueForKey:@"id"];
    newPhoto.name = [dictionary valueForKey:@"name"];
    newPhoto.position = [dictionary valueForKey:@"position"];
    
    // Photo
    newPhoto.picture = [dictionary valueForKey:@"picture"];
    newPhoto.source = [dictionary valueForKey:@"source"];
    
    // Dimensions
    newPhoto.width = [dictionary valueForKey:@"width"];
    newPhoto.height = [dictionary valueForKey:@"height"];
    
    // Author/From
    NSDictionary *from = [dictionary valueForKey:@"from"];
    newPhoto.fromId = [from valueForKey:@"id"];
    newPhoto.fromName = [from valueForKey:@"name"];
    
    // Timestamp
    if ([dictionary valueForKey:@"updated_time"]) {
      newPhoto.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"updated_time"]];
    } else if ([dictionary valueForKey:@"created_time"]) {
      newPhoto.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"created_time"]];
    } else {
      newPhoto.timestamp = [NSDate distantPast];
    }
    
    return newPhoto;
  } else {
    return nil;
  }
}

- (Photo *)updatePhotoWithDictionary:(NSDictionary *)dictionary {  
  if (dictionary) {
    // Basic
    self.id = [dictionary valueForKey:@"id"];
    self.name = [dictionary valueForKey:@"name"];
    self.position = [dictionary valueForKey:@"position"];
    
    // Photo
    self.picture = [dictionary valueForKey:@"picture"];
    self.source = [dictionary valueForKey:@"source"];
    
    // Dimensions
    self.width = [dictionary valueForKey:@"width"];
    self.height = [dictionary valueForKey:@"height"];
    
    // Author/From
    NSDictionary *from = [dictionary valueForKey:@"from"];
    self.fromId = [from valueForKey:@"id"];
    self.fromName = [from valueForKey:@"name"];
    
    // Timestamp
    if ([dictionary valueForKey:@"updated_time"]) {
      self.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"updated_time"]];
    } else if ([dictionary valueForKey:@"created_time"]) {
      self.timestamp = [NSDate dateFromFacebookTimestamp:[dictionary valueForKey:@"created_time"]];
    } else {
      self.timestamp = [NSDate distantPast];
    }
    
    return self;
  } else {
    return nil;
  }
}

@end

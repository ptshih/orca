//
//  Kupo+Serialize.m
//  Moogle
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
    newKupo.timestamp = [NSDate dateWithTimeIntervalSince1970:[[dictionary valueForKey:@"timestamp"] longLongValue]];
    
    // Conditional
    newKupo.comment = [dictionary valueForKey:@"comment"] ? [dictionary valueForKey:@"comment"] : nil;
    
    return newKupo;
  } else {
    return nil;
  }
}

@end

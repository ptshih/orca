//
//  EventDataCenter.h
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface EventDataCenter : PSDataCenter {
  NSManagedObjectContext *_context;
}

@property (nonatomic, retain) NSManagedObjectContext *context;

- (void)getEventsWithSince:(NSDate *)sinceDate;
- (void)loadMoreEventsWithUntil:(NSDate *)untilDate;

- (void)loadEventsFromFixture;

/**
 Serialize server response into Event entities
 */
- (void)serializeEventsWithDictionary:(NSDictionary *)dictionary;

/**
 Fetch Requests
 */
- (NSFetchRequest *)getEventsFetchRequest;

@end

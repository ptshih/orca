//
//  KupoDataCenter.h
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface KupoDataCenter : PSDataCenter {
  NSManagedObjectContext *_context;
}

@property (nonatomic, retain) NSManagedObjectContext *context;

- (void)getKuposForEventWithEventId:(NSString *)placeId andSince:(NSDate *)sinceDate;
- (void)loadMoreKuposForEventWithEventId:(NSString *)placeId andUntil:(NSDate *)untilDate;

- (void)loadKuposFromFixture;

- (void)serializeKuposWithDictionary:(NSDictionary *)dictionary;

/**
 Fetch Requests
 */
- (NSFetchRequest *)getKuposFetchRequestWithEventId:(NSString *)placeId;

@end

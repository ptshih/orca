//
//  FollowedDataCenter.m
//  Scrapboard
//
//  Created by Peter Shih on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FollowedDataCenter.h"

static FollowedDataCenter *_defaultCenter = nil;

@implementation FollowedDataCenter

#pragma mark -
#pragma mark Shared Instance
+ (id)defaultCenter {
  @synchronized(self) {
    if (_defaultCenter == nil) {
      _defaultCenter = [[self alloc] init];
    }
    return _defaultCenter;
  }
}

- (id)init {
  self = [super init];
  if (self) {
    _apiEndpoint = [@"users/me/followed" retain];
  }
  return self;
}

#pragma mark Fetch Requests
- (NSFetchRequest *)getEventsFetchRequest { 
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getFollowedEvents" substitutionVariables:[NSDictionary dictionary]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  //  [fetchRequest setFetchLimit:limit];
  return fetchRequest;
}

@end

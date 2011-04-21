//
//  FirehoseDataCenter.m
//  Scrapboard
//
//  Created by Peter Shih on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FirehoseDataCenter.h"

static FirehoseDataCenter *_defaultCenter = nil;

@implementation FirehoseDataCenter

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
    _apiEndpoint = [@"users/me/events" retain];
  }
  return self;
}

#pragma mark Fetch Requests
- (NSFetchRequest *)getEventsFetchRequest { 
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:NO] autorelease];
  NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
  NSFetchRequest * fetchRequest = [[LICoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getAllEvents" substitutionVariables:[NSDictionary dictionary]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  //  [fetchRequest setFetchLimit:limit];
  return fetchRequest;
}

@end

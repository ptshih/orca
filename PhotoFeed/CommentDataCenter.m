//
//  CommentDataCenter.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentDataCenter.h"
#import "Comment.h"
#import "Comment+Serialize.h"
#import "Photo.h"

@implementation CommentDataCenter

#pragma mark -
#pragma mark Fetch Request
- (NSFetchRequest *)fetchCommentsForPhoto:(Photo *)photo {
  NSSortDescriptor *sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES] autorelease];
  NSArray *sortDescriptors = [[[NSArray alloc] initWithObjects:sortDescriptor, nil] autorelease];
  NSFetchRequest *fetchRequest = [[PSCoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:@"getCommentsForPhoto" substitutionVariables:[NSDictionary dictionaryWithObject:photo forKey:@"desiredPhoto"]];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setFetchBatchSize:10];
  return fetchRequest;
}

@end

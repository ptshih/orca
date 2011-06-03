//
//  CardCoreDataTableViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CardTableViewController.h"
#import "PSCoreDataStack.h"

@interface CardCoreDataTableViewController : CardTableViewController <NSFetchedResultsControllerDelegate> {  
  NSManagedObjectContext *_context;
  NSFetchedResultsController * _fetchedResultsController;
  NSString * _sectionNameKeyPathForFetchedResultsController;
  NSUInteger _limit;
  NSUInteger _offset;
  NSUInteger _lastFetchedCount;
  NSTimer *_searchTimer;
  NSPredicate *_searchPredicate;
}

@property (nonatomic, assign) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, retain) NSString * sectionNameKeyPathForFetchedResultsController;


- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;

- (void)delayedFilterContentWithTimer:(NSTimer *)timer;

- (void)resetFetchedResultsController;
- (void)executeFetch;
- (NSFetchRequest *)getFetchRequest;
- (void)coreDataDidReset;

@end

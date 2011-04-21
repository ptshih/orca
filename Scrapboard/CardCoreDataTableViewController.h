//
//  CardCoreDataTableViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CardTableViewController.h"
#import "LICoreDataStack.h"

@interface CardCoreDataTableViewController : CardTableViewController <NSFetchedResultsControllerDelegate> {  
  NSManagedObjectContext *_context;
  NSFetchedResultsController * _fetchedResultsController;
  NSString * _sectionNameKeyPathForFetchedResultsController;
}

@property (nonatomic, assign) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;
@property (nonatomic, retain) NSString * sectionNameKeyPathForFetchedResultsController;


- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)executeFetch;
- (NSFetchRequest *)getFetchRequest;

@end

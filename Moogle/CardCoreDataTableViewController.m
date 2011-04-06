    //
//  CardCoreDataTableViewController.m
//  Moogle
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import "CardCoreDataTableViewController.h"
#import "LICoreDataStack.h"

@interface CardCoreDataTableViewController (Private)


@end

@implementation CardCoreDataTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize sectionNameKeyPathForFetchedResultsController = _sectionNameKeyPathForFetchedResultsController;

- (id)init {
  self = [super init];
  if (self) {
    _fetchedResultsController = nil;
    _sectionNameKeyPathForFetchedResultsController = nil;
    _cachedPredicate = nil;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self resetFetchedResultsController];
}

#pragma mark State Machine
- (BOOL)dataIsAvailable {
  return (_fetchedResultsController && _fetchedResultsController.fetchedObjects.count > 0);
}

- (BOOL)dataIsLoading {
  return NO;
}

- (void)updateState {
  [super updateState];
}

#pragma mark Data Source
- (void)reloadCardController {
  [super reloadCardController];
  [self executeFetchWithPredicate:nil];
}

#pragma mark Core Data
- (void)resetFetchedResultsController {
  if ([LICoreDataStack managedObjectContext]) {
//    // NOTE: Should we be resetting this?
//    [[LICoreDataStack managedObjectContext] reset];
    
    if (_fetchedResultsController) {
      _fetchedResultsController.delegate = nil;
      _fetchedResultsController = nil;
    }

    NSFetchRequest *fetchRequest = [self getFetchRequest];
    if (fetchRequest) {
      _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[LICoreDataStack managedObjectContext] sectionNameKeyPath:self.sectionNameKeyPathForFetchedResultsController cacheName:nil];
      _fetchedResultsController.delegate = self;
      
      // Cache the original predicate
      if ([fetchRequest predicate]) {
        _cachedPredicate = [[fetchRequest predicate] retain];
      }
    }
  }
}

- (void)executeFetchWithPredicate:(NSPredicate *)predicate {
  NSFetchRequest *fetchRequest = [self.fetchedResultsController fetchRequest];
  
  // Set predicate if exists
  if (predicate) {
    [fetchRequest setPredicate:predicate];
  } else {
    [fetchRequest setPredicate:_cachedPredicate];
  }
  
  NSError *error;
  if ([self.fetchedResultsController performFetch:&error]) {
    DLog(@"Fetch request succeeded: %@", fetchRequest);
  }
  
  [self updateState];  
}

- (NSFetchRequest *)getFetchRequest {
  // Subclass MUST implement
  return nil;
}

#pragma mark NSFetchedresultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  if (self.searchDisplayController.active) {
    [self.searchDisplayController.searchResultsTableView beginUpdates];
  } else {
    [self.tableView beginUpdates];
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
  UITableView *tableView = nil;
  if (self.searchDisplayController.active) {
    tableView = self.searchDisplayController.searchResultsTableView;
  } else {
    tableView = self.tableView;
  }
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate: {
      [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }      
      break;
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  if (self.searchDisplayController.active) {
    [self.searchDisplayController.searchResultsTableView endUpdates];
  } else {
    [self.tableView endUpdates];
  }  
}

#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  // SUBCLASS MUST IMPLEMENT
  
  NSPredicate *predicate = nil;
  
  if ([scope isEqualToString:@"Person"]) {
    // search friend's full name
    predicate = [NSPredicate predicateWithFormat:@"friendFullNames CONTAINS[cd] %@", searchText];
  } else {
    // default to place name
    predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
  }
  
  [self executeFetchWithPredicate:predicate];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
  [self executeFetchWithPredicate:nil];
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell", [self class]];
  UITableViewCell *cell = nil;
  cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  cell.textLabel.text = @"Oops! Forgot to override this method?";
  cell.detailTextLabel.text = reuseIdentifier;
  return cell;
}

- (void)dealloc {
  RELEASE_SAFELY (_fetchedResultsController);
  RELEASE_SAFELY (_sectionNameKeyPathForFetchedResultsController);
  RELEASE_SAFELY(_cachedPredicate);
  [super dealloc];
}

@end

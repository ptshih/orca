//
//  CardCoreDataTableViewController.m
//  Orca
//
//  Created by Peter Shih on 2/16/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import "CardCoreDataTableViewController.h"
#import "PSCoreDataStack.h"

@interface CardCoreDataTableViewController (Private)


@end

@implementation CardCoreDataTableViewController

@synthesize context = _context;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize sectionNameKeyPathForFetchedResultsController = _sectionNameKeyPathForFetchedResultsController;

- (id)init {
  self = [super init];
  if (self) {
    _context = nil;
    _fetchedResultsController = nil;
    _sectionNameKeyPathForFetchedResultsController = nil;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changesSaved:) name:NSManagedObjectContextDidSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
  }
  return self;
}

- (void)loadView {
  [super loadView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

#pragma mark State Machine
- (BOOL)dataIsAvailable {
  return (_fetchedResultsController && _fetchedResultsController.fetchedObjects.count > 0);
}

- (void)updateState {
  [super updateState];
}

#pragma mark Data Source
- (void)reloadCardController {
  [super reloadCardController];
}

- (void)unloadCardController {
  [super unloadCardController];
}

- (void)loadMore {
  [super loadMore];
}

- (void)dataSourceDidLoad {
  [super dataSourceDidLoad];
}

#pragma mark Core Data
- (void)changesSaved:(NSNotification *)notification {
  [self performSelectorOnMainThread:@selector(changesSavedOnMainThread:) withObject:notification waitUntilDone:YES];
}
   
- (void)changesSavedOnMainThread:(NSNotification *)notification {
  if ([notification object] != self.context) {
    [self.context mergeChangesFromContextDidSaveNotification:notification];
  }
}

- (void)resetFetchedResultsController {
  RELEASE_SAFELY(_fetchedResultsController);
  
  // Get a new context
  self.context = [PSCoreDataStack mainThreadContext];
}

- (NSFetchedResultsController*)fetchedResultsController  {
  if (_fetchedResultsController) return _fetchedResultsController;
  
  _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self getFetchRequest] managedObjectContext:self.context sectionNameKeyPath:self.sectionNameKeyPathForFetchedResultsController cacheName:nil];
  _fetchedResultsController.delegate = self;
  
  return _fetchedResultsController;
}

- (void)executeFetch:(BOOL)updateFRC {
  static dispatch_queue_t coreDataFetchQueue = nil;
  if (!coreDataFetchQueue) {
    coreDataFetchQueue = dispatch_queue_create("com.sevenminutelabs.coreDataFetchQueue", NULL);
  }
  
  dispatch_async(coreDataFetchQueue, ^{
    NSError *error = nil;
    NSFetchRequest *backgroundFetch = [[self getFetchRequest] copy];
    
    [backgroundFetch setResultType:NSManagedObjectIDResultType];
//    [backgroundFetch setSortDescriptors:nil];
    NSPredicate *predicate = [backgroundFetch predicate];
    NSPredicate *combinedPredicate = nil;
    if (_searchPredicate) {
      if (predicate) {
        combinedPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, _searchPredicate, nil]];
      } else {
        combinedPredicate = _searchPredicate;
      }
      [backgroundFetch setPredicate:combinedPredicate];
    }
    
    NSManagedObjectContext *context = [PSCoreDataStack newManagedObjectContext];
    NSArray *results = [context executeFetchRequest:backgroundFetch error:&error];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (error) {
      [userInfo setObject:error forKey:@"error"];
    }
    if (results) {
      [userInfo setObject:results forKey:@"results"];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
      if (updateFRC) {
        NSError *frcError = nil;
        NSPredicate *frcPredicate = [NSPredicate predicateWithFormat:@"self IN %@", results];
        [self.fetchedResultsController.fetchRequest setPredicate:frcPredicate];
        if ([self.fetchedResultsController performFetch:&frcError]) {
          VLog(@"Fetch request succeeded: %@", [self.fetchedResultsController fetchRequest]);

          if (self.searchDisplayController.active) {
            [self.searchDisplayController.searchResultsTableView reloadData];
          } else {
            [_tableView reloadData];
            [self updateState];
          }
        } else {
          VLog(@"Fetch failed with error: %@", [error localizedDescription]);
        }
        
        // Reset the FRC predicate so that it gets delegate callbacks
        [self.fetchedResultsController.fetchRequest setPredicate:nil];
      }
      
      [context release];
      [backgroundFetch release];
      [userInfo release];
    });
  });
}

- (NSFetchRequest *)getFetchRequest {
  // Subclass MUST implement
  return nil;
}

#pragma mark NSFetchedresultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
  [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
  
  UITableView *tableView = _tableView;
  
  DLog(@"type: %d, old indexPath: %@, new indexPath: %@, class: %@", type, indexPath, newIndexPath, NSStringFromClass([self class]));
  
  switch(type) {
    case NSFetchedResultsChangeInsert:
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeDelete:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
      
    case NSFetchedResultsChangeUpdate:{
      [self tableView:tableView configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
    }
    case NSFetchedResultsChangeMove:
      [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
      [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
  [_tableView endUpdates];
  [self updateState];
}

#pragma mark UISearchDisplayDelegate
- (void)delayedFilterContentWithTimer:(NSTimer *)timer {
  // SUBCLASS MUST IMPLEMENT
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  if (_searchTimer && [_searchTimer isValid]) {
    INVALIDATE_TIMER(_searchTimer);
  }
  NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:searchText, @"searchText", scope, @"scope", nil];
  _searchTimer = [[NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(delayedFilterContentWithTimer:) userInfo:userInfo repeats:NO] retain];
  [[NSRunLoop currentRunLoop] addTimer:_searchTimer forMode:NSDefaultRunLoopMode];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  [super searchDisplayControllerWillBeginSearch:controller];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
  [super searchDisplayControllerWillEndSearch:controller];
  _searchPredicate = nil;
  [self executeFetch:YES];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
  
  // Return NO if we are using coreData to background fetch (because we need to manually reload the table after the fetch is finished
  return NO;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
  [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
  
  // Return NO if we are using coreData to background fetch (because we need to manually reload the table after the fetch is finished
  return NO;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  // subclass must implement
  // This is only called by the NSFetchedResultsDelegate when a row is updated
}

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

- (void)coreDataDidReset {
  [self resetFetchedResultsController];
  if (self.searchDisplayController) {
    [self.searchDisplayController setActive:NO];
  } else {
    [self.tableView reloadData];
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kCoreDataDidReset object:nil];
  RELEASE_SAFELY(_fetchedResultsController);
  RELEASE_SAFELY(_sectionNameKeyPathForFetchedResultsController);
  RELEASE_SAFELY(_searchPredicate);
  INVALIDATE_TIMER(_searchTimer);
  [super dealloc];
}

@end

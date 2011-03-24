    //
//  CardCoreDataTableViewController.m
//  Prototype
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
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
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
    }
  
    // Should we automatically perform a fetch here?
    NSError *error;
    if ([self.fetchedResultsController performFetch:&error]) {
      DLog(@"Fetch request succeeded: %@", fetchRequest);
    }
  }
}
    
- (NSFetchRequest *)getFetchRequest {
  // Subclass MUST implement
  return nil;
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
  [super dealloc];
}

@end

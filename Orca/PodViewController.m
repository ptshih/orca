//
//  PodViewController.m
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PodViewController.h"
#import "PodDataCenter.h"
#import "MessageViewController.h"
#import "Pod.h"
#import "PodCell.h"

@implementation PodViewController

- (id)init {
  self = [super init];
  if (self) {
    _sectionNameKeyPathForFetchedResultsController = nil;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[PodDataCenter defaultCenter] setDelegate:self];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kReloadPodController object:nil];
  [self reloadCardController];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[PodDataCenter defaultCenter] setDelegate:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadPodController object:nil];
}

- (void)loadView {
  [super loadView];
  
  [self resetFetchedResultsController];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  // Title and Buttons
  [self addButtonWithTitle:@"Logout" andSelector:@selector(logout) isLeft:YES];
//  [self addButtonWithTitle:@"Search" andSelector:@selector(search) isLeft:NO];
//  [self addButtonWithImage:[UIImage imageNamed:@"searchbar_textfield_background.png"] andSelector:@selector(search) isLeft:NO];
  
  _navTitleLabel.text = @"Orca Pods";
  
  // Search
  [self setupSearchDisplayControllerWithScopeButtonTitles:nil andPlaceholder:@"Search Pods..."];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  [self setupTableFooter];
  
//  [self setupLoadMoreView];
  
  [self executeFetch:YES];
}

- (void)reloadCardController {
  [super reloadCardController];
  if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
//    [[PodDataCenter defaultCenter] getPodsFromFixtures];
    [[PodDataCenter defaultCenter] getPods];
  }
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark TableView
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Pod *pod = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [PodCell rowHeightForObject:pod forInterfaceOrientation:[self interfaceOrientation]];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//  return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//  if ([[self.fetchedResultsController sections] count] == 1) return nil;
//  
//  NSString *sectionName = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
//  
//  UIView *sectionHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 26)] autorelease];
//  sectionHeaderView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_plain_header_gray.png"]];
//  
//  UILabel *sectionHeaderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 0, 310, 26)] autorelease];
//  sectionHeaderLabel.backgroundColor = [UIColor clearColor];
//  sectionHeaderLabel.text = sectionName;
//  sectionHeaderLabel.textColor = [UIColor whiteColor];
//  sectionHeaderLabel.shadowColor = [UIColor blackColor];
//  sectionHeaderLabel.shadowOffset = CGSizeMake(0, 1);
//  sectionHeaderLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
//  [sectionHeaderView addSubview:sectionHeaderLabel];
//  return sectionHeaderView;
//}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Pod *pod = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:pod];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  Pod *pod = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  MessageViewController *mvc = [[MessageViewController alloc] init];
  mvc.pod = pod;
  [self.navigationController pushViewController:mvc animated:YES];
  [mvc release];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  PodCell *cell = nil;
  NSString *reuseIdentifier = [PodCell reuseIdentifier];
  
  cell = (PodCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[PodCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  [self tableView:tableView configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//  [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
//  [(AlbumCell *)cell loadPhoto];
//}

#pragma mark -
#pragma mark UISearchDisplayDelegate
- (void)delayedFilterContentWithTimer:(NSTimer *)timer {
  static NSCharacterSet *separatorCharacterSet = nil;
  if (!separatorCharacterSet) {
    separatorCharacterSet = [[[NSCharacterSet alphanumericCharacterSet] invertedSet] retain];
  }
  
  NSDictionary *userInfo = [timer userInfo];
  NSString *searchText = [userInfo objectForKey:@"searchText"];
  NSString *scope = [userInfo objectForKey:@"scope"];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSMutableArray *subpredicates = [NSMutableArray arrayWithCapacity:1];
    //  predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@", searchText];
    
    NSString *tmp = [[searchText componentsSeparatedByCharactersInSet:separatorCharacterSet] componentsJoinedByString:@" "];
    NSArray *searchTerms = [tmp componentsSeparatedByString:@" "];
    
    for (NSString *searchTerm in searchTerms) {
      if ([searchTerm length] == 0) continue;
      NSString *searchValue = searchTerm;
      // search any
      [subpredicates addObject:[NSPredicate predicateWithFormat:@"name CONTAINS[cd] %@ OR fromName CONTAINS[cd] %@ OR participants CONTAINS[cd] %@", searchValue, searchValue, searchValue]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      if (_searchPredicate) {
        RELEASE_SAFELY(_searchPredicate);
      }
      _searchPredicate = [[NSCompoundPredicate andPredicateWithSubpredicates:subpredicates] retain];
      
      [self executeFetch:YES];
    });
  });
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  NSString *sortKey = @"timestamp";
  NSString *fetchTemplate = @"getPods";
  NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortKey ascending:NO]];
  NSDictionary *substitutionVariables = nil;
  
  
  NSFetchRequest *fetchRequest = [[PSCoreDataStack managedObjectModel] fetchRequestFromTemplateWithName:fetchTemplate substitutionVariables:substitutionVariables];
  [fetchRequest setSortDescriptors:sortDescriptors];
  [fetchRequest setFetchBatchSize:10];
  
  return fetchRequest;
}

- (void)logout {
  UIAlertView *logoutAlert = [[UIAlertView alloc] initWithTitle:@"Logout?" message:LOGOUT_ALERT delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
  [logoutAlert show];
  [logoutAlert autorelease];
}

#pragma mark -
#pragma mark AlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex != alertView.cancelButtonIndex) {
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutRequested object:nil];
  }
}

- (void)dealloc {
  [super dealloc];
}

@end

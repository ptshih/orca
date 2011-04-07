    //
//  CardTableViewController.m
//  Moogle
//
//  Created by Peter Shih on 2/14/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import "CardTableViewController.h"
#import "MoogleCell.h"
#import "MoogleImageCell.h"

@interface CardTableViewController (Private)

@end

@implementation CardTableViewController

@synthesize tableView = _tableView;
@synthesize sections = _sections;
@synthesize items = _items;
@synthesize searchItems = _searchItems;
@synthesize headerTabView = _headerTabView;

- (id)init {
  self = [super init];
  if (self) {    
    _sections = [[NSMutableArray alloc] initWithCapacity:1];
    _items = [[NSMutableArray alloc] initWithCapacity:1];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
}

// SUBCLASS CAN OPTIONALLY IMPLEMENT IF THEY WANT A SEARCH BAR
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles {
  _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  _searchBar.delegate = self;
  if (scopeButtonTitles) {
    _searchBar.scopeButtonTitles = scopeButtonTitles;
  }
  self.tableView.tableHeaderView = _searchBar;
  
  UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
  [searchController setDelegate:self];
  [searchController setSearchResultsDelegate:self];
  [searchController setSearchResultsDataSource:self];
  
  // SUBCLASSES MUST IMPLEMENT THE DELEGATE METHODS
  _searchItems = [[NSMutableArray alloc] initWithCapacity:1];
  
  // UITableViewCellSeparatorStyleNone
}

// SUBCLASS SHOULD CALL THIS
- (void)setupTableViewWithFrame:(CGRect)frame andStyle:(UITableViewStyle)style andSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle {
  _tableView = [[UITableView alloc] initWithFrame:frame style:style];
  _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  _tableView.separatorStyle = separatorStyle;
  _tableView.delegate = self;
  _tableView.dataSource = self;
  if (style == UITableViewStylePlain) {
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorColor = SEPARATOR_COLOR;
  }
//  [self.view insertSubview:self.tableView atIndex:0];
  [self.view addSubview:_tableView];
  
  // Set the active scrollView
  _activeScrollView = _tableView;
}

// SUBCLASS CAN OPTIONALLY CALL
- (void)setupPullRefresh {
  if (_refreshHeaderView == nil) {
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
		[self.tableView addSubview:_refreshHeaderView];		
	}
	
  //  update the last update date
  [_refreshHeaderView refreshLastUpdatedDate];
}

- (void)setupHeaderTabView {
  _headerTabView = [[HeaderTabView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 44.0) andButtonTitles:[NSArray arrayWithObjects:@"Nearby", @"Popular", @"Followed", nil]];
  self.headerTabView.delegate = self;
  
  self.tableView.tableHeaderView = self.headerTabView;
}

// Optional footer view
- (void)setupFooterView {
  _tableView.frame = CGRectMake(_tableView.left, _tableView.top, _tableView.width, _tableView.height - 40);
  _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 40, 320, 40)];
  _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  _footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"gradient_gray.png"]];

  [self.view addSubview:_footerView];
}

- (void)setupLoadMoreView {
  _loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _loadMoreView.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
  
  // Button
  _loadMoreButton = [[UIButton alloc] initWithFrame:_loadMoreView.frame];
  _loadMoreButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"navigationbar_bg.png"] forState:UIControlStateNormal];
  [_loadMoreButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
  [_loadMoreButton setTitle:@"Load More..." forState:UIControlStateNormal];
  [_loadMoreButton.titleLabel setShadowColor:[UIColor blackColor]];
  [_loadMoreButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
  [_loadMoreButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
  
  // Activity
  _loadMoreActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  _loadMoreActivity.frame = CGRectMake(12, 12, 20, 20);
  _loadMoreActivity.hidesWhenStopped = YES;
  
  // Add to subview
  [_loadMoreView addSubview:_loadMoreButton];
  [_loadMoreView addSubview:_loadMoreActivity];
}

- (void)showLoadMoreView {
  if (_loadMoreView) {
    [_loadMoreActivity stopAnimating];
    _loadMoreButton.enabled = YES;
    _tableView.tableFooterView = _loadMoreView;
  }
}

- (void)hideLoadMoreView {
  if (_loadMoreView) {
    _loadMoreButton = NO;
    _tableView.tableFooterView = nil;
  }
}

// Subclasses should override
- (void)loadMore {
  [_loadMoreActivity startAnimating];
  _loadMoreButton.enabled = NO;
}

// Called when the user logs out and we need to clear all cached data
// Subclasses should override this method
- (void)clearCachedData {
  [self.sections removeAllObjects];
  [self.items removeAllObjects];
  [self.tableView reloadData];
  [self dataSourceDidLoad];
}

- (void)reloadCardController {
  [super reloadCardController];
  _reloading = YES;
  [_refreshHeaderView setState:EGOOPullRefreshLoading];
}

- (void)unloadCardController {
  [super unloadCardController];
  [_tableView reloadData];
}

- (void)dataSourceDidLoad {
  [super dataSourceDidLoad];
  _reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
  
  // Is this a load more call?
  [self showLoadMoreView];
}

#pragma mark CardStateMachine
- (BOOL)dataIsAvailable {
  if (_tableView == self.searchDisplayController.searchResultsTableView) {
    return ([_searchItems count] > 0);
  } else {
    return ([[self.items objectAtIndex:0] count] > 0); // check section 0
  }
}

- (BOOL)dataSourceIsReady {
  return ([self.sections count] > 0);
}


#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return 1;
  } else {
    return [self.sections count];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return [self.searchItems count];
  } else {
    return [[self.items objectAtIndex:section] count];
  }
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

#pragma mark UISearchDisplayDelegate
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
  // SUBCLASS MUST IMPLEMENT
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
  [self filterContentForSearchText:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
  
  // Return YES to cause the search result table view to be reloaded.
  return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
  [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
  
  // Return YES to cause the search result table view to be reloaded.
  return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
  tableView.backgroundColor = VERY_LIGHT_GRAY;
  tableView.separatorColor = SEPARATOR_COLOR;
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
}

#pragma mark HeaderTabViewDelegate
- (void)tabSelectedAtIndex:(NSNumber *)index {
  // MUST SUBCLASS
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!self.searchDisplayController.active) {
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view {
  [self reloadCardController];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view {
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view {
	return [NSDate date]; // should return date data source was last changed
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  RELEASE_SAFELY(_tableView);
  RELEASE_SAFELY(_sections);
  RELEASE_SAFELY(_items);
  RELEASE_SAFELY(_searchItems);
  RELEASE_SAFELY(_searchBar);
  RELEASE_SAFELY(_refreshHeaderView);
  RELEASE_SAFELY(_headerTabView);
  RELEASE_SAFELY(_footerView);
  RELEASE_SAFELY(_loadMoreView);
  RELEASE_SAFELY(_loadMoreButton);
  RELEASE_SAFELY(_loadMoreActivity);
  [self.searchDisplayController release];
  [super dealloc];
}

@end
//
//  CardTableViewController.m
//  Orca
//
//  Created by Peter Shih on 2/14/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import "CardTableViewController.h"
#import "PSCell.h"
#import "PSImageCell.h"

@interface CardTableViewController (Private)

@end

@implementation CardTableViewController

@synthesize tableView = _tableView;
@synthesize items = _items;
@synthesize searchItems = _searchItems;

- (id)init {
  self = [super init];
  if (self) {    
    _items = [[NSMutableArray alloc] initWithCapacity:1];
  }
  return self;
}

- (void)loadView {
  [super loadView];
}

// SUBCLASS CAN OPTIONALLY IMPLEMENT IF THEY WANT A SEARCH BAR
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles {
  [self setupSearchDisplayControllerWithScopeButtonTitles:scopeButtonTitles andPlaceholder:nil];
}

- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles andPlaceholder:(NSString *)placeholder {
  _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  _searchBar.delegate = self;
//  _searchBar.tintColor = [UIColor darkGrayColor];
  _searchBar.placeholder = placeholder;
  _searchBar.barStyle = UIBarStyleBlackOpaque;
  //  _searchBar.backgroundColor = [UIColor clearColor];
  
  if (scopeButtonTitles) {
    _searchBar.scopeButtonTitles = scopeButtonTitles;
  }
  
  _tableView.tableHeaderView = _searchBar;
  
  UISearchDisplayController *searchController = [[UISearchDisplayController alloc] initWithSearchBar:_searchBar contentsController:self];
  [searchController setDelegate:self];
  [searchController setSearchResultsDelegate:self];
  [searchController setSearchResultsDataSource:self];
  
  // SUBCLASSES MUST IMPLEMENT THE DELEGATE METHODS
  _searchItems = [[NSMutableArray alloc] initWithCapacity:1];
  
  // UITableViewCellSeparatorStyleNone
  id searchBarTextField = nil;
  id segmentedControl = nil;
  for (UIView *subview in _searchBar.subviews) {
    if ([subview isMemberOfClass:NSClassFromString(@"UISearchBarBackground")]) {
    } else if ([subview isMemberOfClass:NSClassFromString(@"UISegmentedControl")]) {
      segmentedControl = subview;
    } else if ([subview isMemberOfClass:NSClassFromString(@"UISearchBarTextField")]) {
      searchBarTextField = subview;
    }
  }
  [_searchBar removeSubviews];
  
//  UIImageView *scopeBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_background.png"]] autorelease];
//  scopeBackground.top -= 1;
//  [segmentedControl insertSubview:scopeBackground atIndex:0];
//  [segmentedControl setSegmentedControlStyle:UISegmentedControlStyleBar];
//  [segmentedControl setTintColor:[UIColor blueColor]];
  
  // Add new background
  UIImageView *searchBackground = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_background.png"]] autorelease];
  searchBackground.top -= 1;
  [_searchBar addSubview:searchBackground];
  [_searchBar addSubview:searchBarTextField];
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
  //  [self.view insertSubview:_tableView atIndex:0];
  [self.view addSubview:_tableView];
  
  // Set the active scrollView
  _activeScrollView = _tableView;
}

// SUBCLASS CAN OPTIONALLY CALL
- (void)setupPullRefresh {
  if (_refreshHeaderView == nil) {
    _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _tableView.bounds.size.height, self.view.frame.size.width, _tableView.bounds.size.height)];
    _refreshHeaderView.delegate = self;
		[_tableView addSubview:_refreshHeaderView];		
	}
	
  //  update the last update date
  [_refreshHeaderView refreshLastUpdatedDate];
}

// Optional table footer
- (void)setupTableFooter {
  UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_footer_background.png"]];
  _tableView.tableFooterView = footerImage;
  [footerImage release];
}

// Optional Header View
- (void)setupHeaderView {
  _tableView.frame = CGRectMake(_tableView.left, _tableView.top + 44, _tableView.width, _tableView.height - 44);
  _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  
  [self.view addSubview:_headerView];
}

// Optional footer view
- (void)setupFooterView {
  _tableView.frame = CGRectMake(_tableView.left, _tableView.top, _tableView.width, _tableView.height - 44);
  _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, 320, 44)];
  _footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  _footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar_bg.png"]];
  
  [self.view addSubview:_footerView];
}

// This is the button load more style
//- (void)setupLoadMoreView {
//  _loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//  _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//  _loadMoreView.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
//  
//  // Button
//  _loadMoreButton = [[UIButton alloc] initWithFrame:_loadMoreView.frame];
//  _loadMoreButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//  _loadMoreButton.userInteractionEnabled = NO;
//  [_loadMoreButton setBackgroundImage:[UIImage imageNamed:@"search_background.png"] forState:UIControlStateNormal];
//  [_loadMoreButton addTarget:self action:@selector(loadMore) forControlEvents:UIControlEventTouchUpInside];
//  [_loadMoreButton setTitle:@"Load More..." forState:UIControlStateNormal];
//  [_loadMoreButton setTitle:@"Loading More..." forState:UIControlStateSelected];
//  [_loadMoreButton.titleLabel setShadowColor:[UIColor blackColor]];
//  [_loadMoreButton.titleLabel setShadowOffset:CGSizeMake(0, 1)];
//  [_loadMoreButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0]];
//  
//  // Activity
//  _loadMoreActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
//  _loadMoreActivity.frame = CGRectMake(12, 12, 20, 20);
//  _loadMoreActivity.hidesWhenStopped = YES;
//  
//  // Add to subview
//  [_loadMoreView addSubview:_loadMoreButton];
//  [_loadMoreView addSubview:_loadMoreActivity];
//  
//  // Always show
//  //  [self showLoadMoreView];
//}

// This is the automatic load more style
- (void)setupLoadMoreView {
  _loadingMore = NO;
  
  _loadMoreView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  _loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _loadMoreView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loadmore-bg.png"]];
  UILabel *loadMoreLabel = [[[UILabel alloc] initWithFrame:_loadMoreView.bounds] autorelease];
  loadMoreLabel.backgroundColor = [UIColor clearColor];
  loadMoreLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  loadMoreLabel.text = @"Loading More...";
  loadMoreLabel.shadowColor = [UIColor blackColor];
  loadMoreLabel.shadowOffset = CGSizeMake(0, 1);
  loadMoreLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
  loadMoreLabel.textColor = [UIColor whiteColor];
  loadMoreLabel.textAlignment = UITextAlignmentCenter;
    
  // Activity
  _loadMoreActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
  _loadMoreActivity.frame = CGRectMake(12, 12, 20, 20);
  _loadMoreActivity.hidesWhenStopped = YES;
  
  // Add to subview
  [_loadMoreView addSubview:loadMoreLabel];
  [_loadMoreView addSubview:_loadMoreActivity];
}

- (void)showLoadMoreView {
  if (_loadMoreView) {
    [_loadMoreActivity startAnimating];
    _tableView.tableFooterView = _loadMoreView;
  }
}

- (void)hideLoadMoreView {
  if (_loadMoreView) {
    _tableView.tableFooterView = nil;
  }
}

// Subclasses should override
- (void)loadMore {
  _loadingMore = YES;
}

- (void)loadMoreIfAvailable {
  if (!_tableView.tableFooterView) {
    return;
  }
  // Make sure we are showing the footer first before attempting to load more
  // Once we begin loading more, this should no longer trigger
  //  NSLog(@"check to load more: %@", NSStringFromCGPoint(_tableView.contentOffset));
  CGFloat tableBottom = _tableView.contentOffset.y + _tableView.height;
  CGFloat footerTop = _tableView.tableFooterView.top;
  
  if (tableBottom >= footerTop) {
    // Footer is showing, start loading more
    if (!_loadingMore) {
      [self loadMore];
    }
  }
}

- (void)updateState {
  [super updateState];
}

// Called when the user logs out and we need to clear all cached data
// Subclasses should override this method
- (void)clearCachedData {
  [self.items removeAllObjects];
  [self dataSourceDidLoad];
}

- (void)reloadCardController {
  [super reloadCardController];
  _reloading = YES;
  if (_refreshHeaderView) {
    [_refreshHeaderView setState:EGOOPullRefreshLoading];
  }
}

- (void)unloadCardController {
  [super unloadCardController];
}

- (void)dataSourceDidLoad {
  [super dataSourceDidLoad];
  _reloading = NO;
  if (_refreshHeaderView) {
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_tableView];
  }
}

#pragma mark CardStateMachine
- (BOOL)dataIsAvailable {
  if (_tableView == self.searchDisplayController.searchResultsTableView) {
    return ([_searchItems count] > 0);
  } else {
    if ([self.items count] > 0) {
      return YES;
    } else {
      return NO;
    }
  }
}

- (BOOL)dataSourceIsReady {
  return ([self.items count] > 0);
}

- (BOOL)dataIsLoading {
  return _reloading;
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
    return [self.items count];
  }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (tableView == self.searchDisplayController.searchResultsTableView) {
    return [self.searchItems count];
  } else {
    return [[self.items objectAtIndex:section] count];
  }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (tableView.style == UITableViewStylePlain) {
    UIView *backgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    backgroundView.backgroundColor = CELL_LIGHT_GRAY_COLOR;
    cell.backgroundView = backgroundView;
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedBackgroundView.backgroundColor = CELL_SELECTED_COLOR;
    cell.selectedBackgroundView = selectedBackgroundView;
    
    [backgroundView release];
    [selectedBackgroundView release];
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
  tableView.backgroundColor = [UIColor blackColor];
  tableView.separatorColor = SEPARATOR_COLOR;
  tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
  // Subclass may implement
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
  // Subclass may implement
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
  if (!decelerate) {
    [self scrollEndedTrigger];
  }
  if (!self.searchDisplayController.active) {
    if (_refreshHeaderView) {
      [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  [self scrollEndedTrigger];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
  if (_refreshHeaderView) {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
  }
}

- (void)scrollEndedTrigger {
  //  [self loadImagesForOnScreenRows];
  [self loadMoreIfAvailable];
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

#pragma mark -
#pragma mark Image Lazy Loading
- (void)loadImagesForOnScreenRows {
  //  NSArray *visibleIndexPaths = nil;
  //  if (self.searchDisplayController.active) {
  //    _visibleCells = [[self.searchDisplayController.searchResultsTableView visibleCells] retain];
  //    _visibleIndexPaths = [[self.searchDisplayController.searchResultsTableView indexPathsForVisibleRows] retain];
  //  } else {
  //    _visibleCells = [[self.tableView visibleCells] retain];
  //    _visibleIndexPaths = [[self.tableView indexPathsForVisibleRows] retain];
  //  }
  
  // Subclass SHOULD IMPLEMENT
  
  //  for (id cell in visibleCells) {
  //    if ([cell isKindOfClass:[PSImageCell class]]) {
  //      [(PSImageCell *)cell loadImage];
  //    }
  //  }
}

- (void)didReceiveMemoryWarning {
  // Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
}

- (void)dealloc {
  RELEASE_SAFELY(_tableView);
  RELEASE_SAFELY(_items);
  RELEASE_SAFELY(_searchItems);
  RELEASE_SAFELY(_searchBar);
  RELEASE_SAFELY(_visibleCells);
  RELEASE_SAFELY(_visibleIndexPaths);
  RELEASE_SAFELY(_refreshHeaderView);
  RELEASE_SAFELY(_headerView);
  RELEASE_SAFELY(_footerView);
  RELEASE_SAFELY(_loadMoreView);
  RELEASE_SAFELY(_loadMoreButton);
  RELEASE_SAFELY(_loadMoreActivity);
  [super dealloc];
}

@end
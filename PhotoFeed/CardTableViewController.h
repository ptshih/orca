//
//  CardTableViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 2/14/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"
#import "HeaderTabView.h"
#import "EGORefreshTableHeaderView.h"

@interface CardTableViewController : CardViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate, EGORefreshTableHeaderDelegate> {
  UITableView *_tableView;
  NSMutableArray *_items;
  NSMutableArray *_searchItems;
  NSArray *_visibleCells;

  UISearchBar *_searchBar;
  EGORefreshTableHeaderView *_refreshHeaderView;
  UIView *_footerView;
  UIView *_loadMoreView;
  UIButton *_loadMoreButton;
  UIActivityIndicatorView *_loadMoreActivity;
  BOOL _reloading;
}

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSMutableArray *searchItems;

- (void)setupTableViewWithFrame:(CGRect)frame andStyle:(UITableViewStyle)style andSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle;
- (void)setupPullRefresh;
- (void)setupFooterView;
- (void)setupLoadMoreView;
- (void)setupSearchDisplayControllerWithScopeButtonTitles:(NSArray *)scopeButtonTitles;

- (void)showLoadMoreView;
- (void)hideLoadMoreView;

- (void)loadMore;

- (void)loadImagesForOnScreenRows;

@end

//
//  PhotoViewController.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoDataCenter.h"
#import "Album.h"
#import "Photo.h"
#import "HeaderCell.h"
#import "PhotoCell.h"
#import "CameraViewController.h"
#import "PSZoomView.h"

@implementation PhotoViewController

@synthesize album = _album;

- (id)init {
  self = [super init];
  if (self) {
    _photoDataCenter = [[PhotoDataCenter alloc] init];
    _photoDataCenter.delegate = self;
    _sectionNameKeyPathForFetchedResultsController = [@"position" retain];
    _headerCellCache = [[NSMutableDictionary alloc] init];
    _limit = 999;
    self.hidesBottomBarWhenPushed = YES;
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCardController) name:kReloadController object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kReloadController object:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Title and Buttons
  _navTitleLabel.text = _album.name;
  
  [self addBackButton];
  [self addButtonWithTitle:@"New" andSelector:@selector(newPhoto) isLeft:NO];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  //  [self setupLoadMoreView];
  
  [self resetFetchedResultsController];
  [self executeFetch];
  [self updateState];
  
  // Get new from server
  [self reloadCardController];
}

- (void)reloadCardController {
  [super reloadCardController];
  
  [_photoDataCenter getPhotosForAlbum:_album];
}

- (void)unloadCardController {
  [super unloadCardController];
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  //  NSLog(@"DC finish with response: %@", response);
  //  [self executeFetch];
  [self dataSourceDidLoad];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self dataSourceDidLoad];
}

#pragma mark -
#pragma mark Compose
- (void)newPhoto {
  //  CameraViewController *cvc = [[CameraViewController alloc] init];
  //  UINavigationController *cnc = [[UINavigationController alloc] initWithRootViewController:cvc];
  //  [self presentModalViewController:cnc animated:YES];
  //  [cvc autorelease];
  //  [cnc autorelease];
}

#pragma mark -
#pragma mark TableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  Photo *photo = [[self.fetchedResultsController fetchedObjects] objectAtIndex:section];
  
  HeaderCell *headerCell = [[[HeaderCell alloc] initWithFrame:CGRectMake(0, 0, 320, 26)] autorelease];
  [headerCell fillCellWithObject:photo];
  //  [headerCell loadImage];
  [_headerCellCache setObject:headerCell forKey:[NSString stringWithFormat:@"%d", section]];
  return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 26.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  return [PhotoCell rowHeightForObject:photo forInterfaceOrientation:[self interfaceOrientation]];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  [cell fillCellWithObject:photo];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  PhotoCell *cell = nil;
  NSString *reuseIdentifier = [NSString stringWithFormat:@"%@_TableViewCell_%d", [self class], indexPath.section];
  
  cell = (PhotoCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
    cell.delegate = self;
  }
  
  [self tableView:tableView configureCell:cell atIndexPath:indexPath];
  
  //  NSLog(@"display");
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  PhotoCell *cell = (PhotoCell *)[tableView cellForRowAtIndexPath:indexPath];
  
  [self zoomPhotoForCell:cell];
}

- (void)zoomPhotoForCell:(PhotoCell *)cell {
  if (!_zoomView) {
    _zoomView = [[PSZoomView alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] frame]];
    _zoomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  }
  
  _zoomView.zoomImageView.image = [[cell.photoView.image copy] autorelease];
  _zoomView.zoomImageView.frame = [cell convertRect:cell.photoView.frame toView:nil];
  _zoomView.oldImageFrame = [cell convertRect:cell.photoView.frame toView:nil];
  _zoomView.oldCaptionFrame = [cell convertRect:cell.captionLabel.frame toView:nil];
  _zoomView.caption = [[cell.captionLabel.text copy] autorelease];
  [_zoomView zoom];
}

- (void)pinchZoomTriggeredForCell:(PhotoCell *)cell {
  [self zoomPhotoForCell:cell];
}

- (void)loadImagesForOnScreenRows {
  [super loadImagesForOnScreenRows];
  
  //  for (id cell in _visibleCells) {
  //    [cell loadPhoto];
  //  }
  
  //  for (NSIndexPath *ip in _visibleIndexPaths) {
  //    HeaderCell *headerCell = [_headerCellCache objectForKey:[NSString stringWithFormat:@"%d", ip.section]];
  //  }
}

#pragma mark -
#pragma mark FetchRequest
- (NSFetchRequest *)getFetchRequest {
  return [_photoDataCenter fetchPhotosForAlbum:_album withLimit:_limit andOffset:_offset];
}

- (void)dealloc {
  _photoDataCenter.delegate = nil;
  RELEASE_SAFELY(_photoDataCenter);
  RELEASE_SAFELY(_headerCellCache);
  RELEASE_SAFELY(_zoomView);
  [super dealloc];
}

@end

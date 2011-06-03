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
#import "CommentViewController.h"

@implementation PhotoViewController

@synthesize album = _album;

- (id)init {
  self = [super init];
  if (self) {
    _photoDataCenter = [[PhotoDataCenter alloc] init];
    _photoDataCenter.delegate = self;
    _sectionNameKeyPathForFetchedResultsController = [@"position" retain];
    _headerCellCache = [[NSMutableDictionary alloc] init];
    _limit = 10;
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

- (void)loadView {
  [super loadView];
  
  [self resetFetchedResultsController];
  
  // Title and Buttons
  _navTitleLabel.text = _album.name;
  
  [self addBackButton];
  [self addButtonWithTitle:@"Favorite" andSelector:@selector(favorite) isLeft:NO];
  
  // Table
  CGRect tableFrame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
  [self setupTableViewWithFrame:tableFrame andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleNone];
  
  // Pull Refresh
  [self setupPullRefresh];
  
  [self setupLoadMoreView];
  
  [self executeFetch];
  
  _album.lastViewed = [NSDate date];
  [PSCoreDataStack saveInContext:[_album managedObjectContext]];
  
  // Get new from server
  [self reloadCardController];
}

- (void)reloadCardController {
  [super reloadCardController];
  
  [_photoDataCenter getPhotosForAlbumId:_album.id];
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
- (void)favorite {
  if ([_album.isFavorite boolValue]) {
    _album.isFavorite = [NSNumber numberWithBool:NO];
  } else {
    _album.isFavorite = [NSNumber numberWithBool:YES];
  }
  [PSCoreDataStack saveInContext:[_album managedObjectContext]];
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
  NSString *reuseIdentifier = [PhotoCell reuseIdentifier];
  
  cell = (PhotoCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[PhotoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
    cell.delegate = self;
  }
  
  [self tableView:tableView configureCell:cell atIndexPath:indexPath];
  [cell loadPhoto];
  
  //  NSLog(@"display");
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  PhotoCell *cell = (PhotoCell *)[tableView cellForRowAtIndexPath:indexPath];
  [self zoomPhotoForCell:cell atIndexPath:indexPath];
}

- (void)zoomPhotoForCell:(PhotoCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  if (!_zoomView) {
    _zoomView = [[PSZoomView alloc] initWithFrame:[[[UIApplication sharedApplication] keyWindow] bounds]];
  }
  
  Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  _zoomView.photo = photo;
  _zoomView.zoomImageView.image = cell.photoView.image;
  _zoomView.zoomImageView.frame = [cell convertRect:cell.photoView.frame toView:nil];
  _zoomView.oldImageFrame = [cell convertRect:cell.photoView.frame toView:nil];
  _zoomView.oldCaptionFrame = [cell convertRect:cell.captionLabel.frame toView:nil];
  _zoomView.caption = [[cell.captionLabel.text copy] autorelease];
  [_zoomView showZoom];
}

#pragma mark -
#pragma mark PhotoCellDelegate
- (void)commentsSelectedForCell:(PhotoCell *)cell {
  NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
  Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
  CommentViewController *cvc = [[CommentViewController alloc] init];
  cvc.photo = photo;
  cvc.photoImage = cell.photoView.image; // copy
  [self.navigationController pushViewController:cvc animated:YES];
  [cvc release];
}

//- (void)pinchZoomTriggeredForCell:(PhotoCell *)cell {
//  [self zoomPhotoForCell:cell];
//}

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
  BOOL ascending = ([self.sectionNameKeyPathForFetchedResultsController isEqualToString:@"position"]) ? YES : NO;
  return [_photoDataCenter fetchPhotosForAlbumId:_album.id withLimit:_limit andOffset:_offset sortWithKey:self.sectionNameKeyPathForFetchedResultsController ascending:ascending];
}

- (void)dealloc {
  _photoDataCenter.delegate = nil;
  RELEASE_SAFELY(_photoDataCenter);
  RELEASE_SAFELY(_headerCellCache);
  RELEASE_SAFELY(_zoomView);
  [super dealloc];
}

@end

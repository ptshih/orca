//
//  PhotoViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

@class PhotoDataCenter;
@class Album;
@class ZoomViewController;

@interface PhotoViewController : CardCoreDataTableViewController {
  PhotoDataCenter *_photoDataCenter;
  Album *_album;
  
  NSMutableDictionary *_headerCellCache;
  ZoomViewController *_zoomViewController;
}

@property (nonatomic, assign) Album *album;

- (void)newPhoto;
- (void)zoomPhotoForCell:(id)cell atIndexPath:(NSIndexPath *)indexPath;

@end

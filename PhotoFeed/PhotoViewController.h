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

@interface PhotoViewController : CardCoreDataTableViewController {
  PhotoDataCenter *_photoDataCenter;
  Album *_album;
  
  NSMutableDictionary *_headerCellCache;
}

@property (nonatomic, assign) Album *album;

- (void)newPhoto;

@end

//
//  AlbumViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

@class AlbumDataCenter;

@interface AlbumViewController : CardCoreDataTableViewController {
  AlbumDataCenter *_albumDataCenter;
}

- (void)newAlbum;

- (void)logout;

@end

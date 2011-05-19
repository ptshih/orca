//
//  AlbumViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

typedef enum {
  AlbumTypeMe = 0,
  AlbumTypeFriends = 1,
  AlbumTypeMobile = 2
} AlbumType;

@interface AlbumViewController : CardCoreDataTableViewController {
  AlbumType _albumType;
}

@property (nonatomic, assign) AlbumType albumType;

- (void)newAlbum;
- (void)logout;

@end

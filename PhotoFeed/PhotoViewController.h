//
//  SnapViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

@class SnapDataCenter;
@class Album;

@interface SnapViewController : CardCoreDataTableViewController {
  SnapDataCenter *_snapDataCenter;
  Album *_album;
}

@property (nonatomic, retain) Album *album;

- (void)newSnap;

@end

//
//  SnapViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

@class SnapDataCenter;

@interface SnapViewController : CardCoreDataTableViewController {
  SnapDataCenter *_snapDataCenter;
  NSString *_albumId;
}

@property (nonatomic, retain) NSString *albumId;

@end

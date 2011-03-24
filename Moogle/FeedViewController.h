//
//  FeedViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

@class FeedDataCenter;

@interface FeedViewController : CardCoreDataTableViewController {
  FeedDataCenter *_feedDataCenter;
  NSNumber *_podId;
}

@property (nonatomic, retain) NSNumber *podId;

@end

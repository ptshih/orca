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
@class Pod;

@interface FeedViewController : CardCoreDataTableViewController {
  FeedDataCenter *_feedDataCenter;
  Pod *_pod;
}

@property (nonatomic, retain) Pod *pod;


@end

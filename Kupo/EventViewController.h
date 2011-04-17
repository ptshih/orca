//
//  EventViewController.h
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"
#import "MeDelegate.h"

@class NearbyViewController;
@class MeViewController;
@class ComposeViewController;

@interface EventViewController : CardCoreDataTableViewController <MeDelegate, UIAlertViewDelegate> {
  NearbyViewController *_nearbyViewController;
  UINavigationController *_nearbyNavController;
  MeViewController *_meViewController;
  UINavigationController *_meNavController;
  ComposeViewController *_composeViewController;
  UINavigationController *_composeNavController;
  NSInteger _limit;
  
  BOOL _shouldReloadOnAppear;
}

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@end

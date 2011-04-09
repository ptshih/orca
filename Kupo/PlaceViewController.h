//
//  PlaceViewController.h
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

@interface PlaceViewController : CardCoreDataTableViewController <MeDelegate, UIAlertViewDelegate> {
  NearbyViewController *_nearbyViewController;
  UINavigationController *_nearbyNavController;
  MeViewController *_meViewController;
  UINavigationController *_meNavController;
  NSInteger _limit;
  
  BOOL _shouldReloadOnAppear;
}

@end

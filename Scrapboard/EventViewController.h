//
//  EventViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"
#import "MeDelegate.h"
#import "KupoViewController.h"
#import "EventComposeViewController.h"
#import "MeViewController.h"
#import "Event.h"
#import "EventCell.h"

@interface EventViewController : CardCoreDataTableViewController <MeDelegate, UIAlertViewDelegate> {
  MeViewController *_meViewController;
  UINavigationController *_meNavController;
  
  BOOL _shouldReloadOnAppear;
}

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

@end

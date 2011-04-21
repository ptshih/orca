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

enum {
  EventTypeFollowed = 0,
  EventTypeFirehose = 1
};
typedef uint32_t EventType;

@interface EventViewController : CardCoreDataTableViewController <MeDelegate, UIAlertViewDelegate> {
  MeViewController *_meViewController;
  UINavigationController *_meNavController;
  
  EventType _eventType;
  BOOL _shouldReloadOnAppear;
}

@property (nonatomic, assign) BOOL shouldReloadOnAppear;

- (void)updateTitle;

@end

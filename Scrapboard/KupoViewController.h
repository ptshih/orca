//
//  ScrapboardViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

@class Event;

@interface KupoViewController : CardCoreDataTableViewController {
  Event *_event;
}

@property (nonatomic, retain) Event *event;

// Private
- (void)composeKupo;

@end

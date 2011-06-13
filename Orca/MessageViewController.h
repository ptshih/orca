//
//  MessageViewController.h
//  Orca
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"
#import "ComposeDelegate.h"

@class Pod;

@interface MessageViewController : CardCoreDataTableViewController <ComposeDelegate> {
  Pod *_pod;
  
  NSMutableDictionary *_headerCellCache;
}

@property (nonatomic, assign) Pod *pod;

- (void)newMessage;

@end

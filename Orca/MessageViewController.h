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

typedef enum {
  MessageCellTypeDefault = 0,
  MessageCellTypePhoto = 1,
  MessageCellTypeMap = 2
} MessageCellType;

@class Pod;
@class PSRollupView;

@interface MessageViewController : CardCoreDataTableViewController <ComposeDelegate> {
  Pod *_pod;
  PSRollupView *_podMembersView;
  
  NSMutableDictionary *_headerCellCache;
}

@property (nonatomic, assign) Pod *pod;

- (id)cellForType:(MessageCellType)cellType withObject:(id)object;
- (void)setupFooter;
- (void)newMessage;
- (void)config;

@end

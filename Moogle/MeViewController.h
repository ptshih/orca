//
//  MeViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModalTableViewController.h"
#import "MoogleImageView.h"
#import "Facebook.h"
#import "MeDelegate.h"

@class MeDataCenter;

@interface MeViewController : CardModalTableViewController <FBDialogDelegate> {
  MeDataCenter *_meDataCenter;
  id <MeDelegate> _delegate;
}

@property (nonatomic, assign) id <MeDelegate> delegate;

// Private
- (void)setupHeader;
- (void)logout;

@end

//
//  MeViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModalTableViewController.h"
#import "PSImageView.h"
#import "Facebook.h"
#import "MeDelegate.h"

@interface MeViewController : CardModalTableViewController <FBDialogDelegate> {
  id <MeDelegate> _delegate;
}

@property (nonatomic, assign) id <MeDelegate> delegate;

// Private
- (void)setupHeader;
- (void)logout;

@end

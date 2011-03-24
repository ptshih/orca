//
//  CardViewController.h
//  Moogle
//
//  Created by Peter Shih on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleViewController.h"
#import "CardStateMachine.h"
#import "UINavigationBar+Custom.h"
#import "MoogleDataCenterDelegate.h"

@interface CardViewController : MoogleViewController <CardStateMachine, MoogleDataCenterDelegate, UINavigationControllerDelegate> {
  UIScrollView *_activeScrollView; // subclasses should set this if they have a scrollView
}

- (void)clearCachedData;
- (void)unloadCardController;
- (void)reloadCardController;
- (void)dataSourceDidLoad;
- (void)setupLoadingAndEmptyViews;

@end

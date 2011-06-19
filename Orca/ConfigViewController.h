//
//  ConfigViewController.h
//  Orca
//
//  Created by Peter Shih on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardTableViewController.h"

@class Pod;

@interface ConfigViewController : CardTableViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
  Pod *_pod;
  
  UIButton *_muteButton;
}

@property (nonatomic, assign) Pod *pod;

- (void)setupFooter;
- (void)mute;
- (void)leave;
- (void)dismiss;

@end

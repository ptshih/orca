//
//  LoginViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"
#import "LoginDelegate.h"
#import "FBConnect.h"

@interface LoginViewController : PSViewController <FBSessionDelegate> {
  Facebook *_facebook;
  UIButton *_loginButton;
  id <LoginDelegate> _delegate;
}

@property (nonatomic, assign) id <LoginDelegate> delegate;
@property (nonatomic, retain) UIButton *loginButton;

@end

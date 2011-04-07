//
//  LoginViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleViewController.h"
#import "LoginDelegate.h"
#import "FBConnect.h"

@interface LoginViewController : MoogleViewController <FBSessionDelegate> {
  Facebook *_facebook;
  UIButton *_loginButton;
  id <LoginDelegate> _delegate;
}

@property (nonatomic, assign) id <LoginDelegate> delegate;

@end

//
//  MoogleAppDelegate.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginDelegate.h"

@class Facebook;
@class LoginViewController;
@class LauncherViewController;
@class PodViewController;

@interface MoogleAppDelegate : NSObject <UIApplicationDelegate, LoginDelegate> {
  UIWindow *_window;
  Facebook *_facebook;
  LoginViewController *_loginViewController;
  LauncherViewController *_launcherViewcontroller;
  PodViewController *_podViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) Facebook *facebook;

// Private
+ (void)setupDefaults;
- (void)saveContext;
- (void)animateHideLogin;

@end

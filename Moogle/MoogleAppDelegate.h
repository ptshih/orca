//
//  MoogleAppDelegate.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginDelegate.h"
#import "MoogleDataCenterDelegate.h"

@class Facebook;
@class LoginViewController;
@class LauncherViewController;
@class PlaceViewController;
@class LoginDataCenter;

@interface MoogleAppDelegate : NSObject <UIApplicationDelegate, LoginDelegate, MoogleDataCenterDelegate> {
  UIWindow *_window;
  Facebook *_facebook;
  LoginViewController *_loginViewController;
  LauncherViewController *_launcherViewcontroller;
  PlaceViewController *_placeViewController;
  UINavigationController *_navigationController;
  
  LoginDataCenter *_loginDataCenter;
  
  // Session
  NSString *_sessionKey;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) Facebook *facebook;
@property (retain) NSString *sessionKey;

// Private
+ (void)setupDefaults;
- (void)saveContext;
- (void)animateHideLogin;
- (void)startSession;
- (void)startRegister;
- (void)tryLogin;

@end

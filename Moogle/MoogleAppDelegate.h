//
//  MoogleAppDelegate.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Facebook;
@class LoginViewController;

@interface MoogleAppDelegate : NSObject <UIApplicationDelegate> {
  UIWindow *_window;
  Facebook *_facebook;
  LoginViewController *_loginViewController;
}

@property (nonatomic, retain) UIWindow *window;
@property (readonly) Facebook *facebook;

// Private
+ (void)setupDefaults;
- (void)saveContext;

@end

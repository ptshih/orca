//
//  LoginViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

@synthesize delegate = _delegate;

- (id)init {
  self = [super init];
  if (self) {
    _facebook = APP_DELEGATE.facebook;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = FB_BLUE_COLOR;
  
  // Setup Logo
  UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-white-280.png"]];
  logo.frame = CGRectMake(20, 44, logo.width, logo.height);
  [self.view addSubview:logo];
  [logo release];
  
  // Setup Login Buttons
  UIButton *login = [[UIButton alloc] initWithFrame:CGRectZero];
  login.width = 280.0;
  login.height = 39.0;
  login.left = 20.0;
  login.top = self.view.height - login.height - 44.0;
  [login setBackgroundImage:[UIImage imageNamed:@"login_facebook.png"] forState:UIControlStateNormal];
  [login setContentEdgeInsets:UIEdgeInsetsMake(-4, 28, 0, 0)];
  [login setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
  [login setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [login setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  login.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
  [login addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:login];
  [login release];
}

#pragma mark -
#pragma mark Button Actions
- (void)login {
  [_facebook authorize:FB_PERMISSIONS delegate:self];
}

#pragma mark -
#pragma mark FBSessionDelegate
- (void)fbDidLogin {
  // Store Access Token
  // ignore the expiration since we request non-expiring offline access
  [[NSUserDefaults standardUserDefaults] setObject:_facebook.accessToken forKey:@"facebookAccessToken"];
  [[NSUserDefaults standardUserDefaults] setObject:_facebook.expirationDate forKey:@"facebookExpirationDate"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(moogleDidLogin)]) {
    [self.delegate performSelector:@selector(moogleDidLogin)];
  }
}

- (void)fbDidNotLogin:(BOOL)cancelled {

}

- (void)fbDidLogout {
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"placesSince"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"placesUntil"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isLoggedIn"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"facebookAccessToken"];
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"facebookExpirationDate"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {
  [super dealloc];
}

@end
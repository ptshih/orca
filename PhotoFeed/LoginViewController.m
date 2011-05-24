//
//  LoginViewController.m
//  PhotoFeed
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginDataCenter.h"

@implementation LoginViewController

@synthesize delegate = _delegate;
@synthesize loginButton = _loginButton;

- (id)init {
  self = [super init];
  if (self) {
    _facebook = APP_DELEGATE.facebook;
    [[LoginDataCenter defaultCenter] setDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout) name:kLogoutRequested object:nil];
  }
  return self;
}

- (void)loadView {
  [super loadView];
  
  self.view.backgroundColor = FB_BLUE_COLOR;
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default.png"]];
  
  // Setup Logo
  //  UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo-white-280.png"]];
  //  logo.frame = CGRectMake(20, 44, logo.width, logo.height);
  //  [self.view addSubview:logo];
  //  [logo release];
  
  // Setup Login Buttons
  _loginButton = [[UIButton alloc] initWithFrame:CGRectZero];
  _loginButton.width = 280.0;
  _loginButton.height = 39.0;
  _loginButton.left = 20.0;
  _loginButton.top = self.view.height - _loginButton.height - 20.0;
  [_loginButton setBackgroundImage:[UIImage imageNamed:@"login_facebook.png"] forState:UIControlStateNormal];
  [_loginButton setContentEdgeInsets:UIEdgeInsetsMake(-4, 28, 0, 0)];
  [_loginButton setTitle:@"Connect with Facebook" forState:UIControlStateNormal];
  [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
  _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
  [_loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_loginButton];
}

#pragma mark -
#pragma mark Button Actions
- (void)login {
  _loginButton.hidden = YES;
  [_facebook authorize:FB_PERMISSIONS delegate:self];
}

- (void)logout {
  [_facebook logout:self];
}

#pragma mark -
#pragma mark FBSessionDelegate
- (void)fbDidLogin {
  // Store Access Token
  // ignore the expiration since we request non-expiring offline access
  [[NSUserDefaults standardUserDefaults] setObject:_facebook.accessToken forKey:@"facebookAccessToken"];
  [[NSUserDefaults standardUserDefaults] setObject:_facebook.expirationDate forKey:@"facebookExpirationDate"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  // We need to get the user's facebookId
  [[LoginDataCenter defaultCenter] getFacebookId];
}

- (void)fbDidNotLogin:(BOOL)cancelled {
  [self logout];
  //  _loginButton.hidden = NO;
}

- (void)fbDidLogout {
  // Clear all user defaults
  [[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(userDidLogout)]) {
    [self.delegate performSelector:@selector(userDidLogout)];
  }
  _loginButton.hidden = NO;
}

#pragma mark -
#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  NSString *facebookId = [response valueForKey:@"id"];
  NSString *facebookName = [response valueForKey:@"name"];
  [[NSUserDefaults standardUserDefaults] setObject:facebookId forKey:@"facebookId"];
  [[NSUserDefaults standardUserDefaults] setObject:facebookName forKey:@"facebookName"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(userDidLogin)]) {
    [self.delegate performSelector:@selector(userDidLogin)];
  }
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self logout];
}

- (void)dealloc {
  [[LoginDataCenter defaultCenter] setDelegate:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kLogoutRequested object:nil];
  RELEASE_SAFELY(_loginButton);
  [super dealloc];
}

@end
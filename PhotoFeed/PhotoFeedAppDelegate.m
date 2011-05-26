//
//  PhotoFeedAppDelegate.m
//  PhotoFeed
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoFeedAppDelegate.h"
#import "Constants.h"
#import "FBConnect.h"
#import "LoginViewController.h"
#import "LauncherViewController.h"
#import "LoginDataCenter.h"
#import "AlbumDataCenter.h"
#import "PSImageCache.h"

@implementation PhotoFeedAppDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;
@synthesize sessionKey = _sessionKey;
@synthesize launcherViewController = _launcherViewController;

+ (void)initialize {
  [self setupDefaults];
}

+ (void)setupDefaults {
  if ([self class] == [PhotoFeedAppDelegate class]) {
    NSString *initialDefaultsPath = [[NSBundle mainBundle] pathForResource:@"InitialDefaults" ofType:@"plist"];
    assert(initialDefaultsPath != nil);
    
    NSDictionary *initialDefaults = [NSDictionary dictionaryWithContentsOfFile:initialDefaultsPath];
    assert(initialDefaults != nil);
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:initialDefaults];
  }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  return [_facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSLog(@"fonts: %@",[UIFont familyNames]);
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"weave-bg.png"]];
  
  // Login/Session/Register data center
  _loginDataCenter = [[LoginDataCenter alloc] init];
  _loginDataCenter.delegate = self;
  
  // Setup Facebook
  _facebook = [[Facebook alloc] initWithAppId:FB_APP_ID];
  
  // LoginVC
  _loginViewController = [[LoginViewController alloc] init];
  _loginViewController.delegate = self;
  
  _launcherViewController = [[LauncherViewController alloc] init];
  
  [self.window addSubview:_launcherViewController.view];
  [self.window makeKeyAndVisible];
  
  // Login if necessary
  [self tryLogin];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  /*
   Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
   Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
   */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  [[NSUserDefaults standardUserDefaults] synchronize];
//  [[PSImageCache sharedCache] flushImageCacheToDisk];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Login if necessary
  [self tryLogin];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  /*
   Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   */
}

- (void)applicationWillTerminate:(UIApplication *)application {
  [[NSUserDefaults standardUserDefaults] synchronize];
//  [[PSImageCache sharedCache] flushImageCacheToDisk];
}


#pragma mark -
#pragma mark Login
- (void)tryLogin {
  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
    if (![_launcherViewController.modalViewController isEqual:_loginViewController] && _loginViewController != nil) {
      [_launcherViewController presentModalViewController:_loginViewController animated:NO];
    }
  } else {
    _facebook.accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"];
    _facebook.expirationDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookExpirationDate"];
    [self startSession];
  }
}

#pragma mark -
#pragma mark LoginDelegate
- (void)userDidLogin {
  DLog(@"User Logged In");
  
  // Set UserDefaults
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
  
  // Session/Register request finished
  if ([_launcherViewController.modalViewController isEqual:_loginViewController]) {
    [_launcherViewController dismissModalViewControllerAnimated:YES];
  }
  
  // Change login screen to edu walkthru / loading
  
  [self startDownloadAlbums];
}

- (void)userDidLogout {
  // Delete all existing data
  [self tryLogin];
  [PSCoreDataStack resetPersistentStore];
}

- (void)startDownloadAlbums {
  [[AlbumDataCenter defaultCenter] setDelegate:self];
#warning disable download at boot if already logged in once
  [[AlbumDataCenter defaultCenter] getAlbums];
}

#pragma mark Session
- (void)startSession {
  // This gets called on subsequent app launches
  [self resetSessionKey];
  [self startDownloadAlbums];
}

- (void)resetSessionKey {
  // Set Session Key
  NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
  NSInteger currentTimestampInteger = floor(currentTimestamp);
  if (_sessionKey) {
    [_sessionKey release], _sessionKey = nil;
  }
  _sessionKey = [[NSString stringWithFormat:@"%d", currentTimestampInteger] retain];
  
  [[NSUserDefaults standardUserDefaults] setValue:_sessionKey forKey:@"sessionKey"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark PSDataCenterDelegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {  
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadAlbumController object:nil];
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  // Session/Register request failed
  // Show login again
  [_loginViewController logout];
}

#pragma mark -
#pragma mark Animations
- (void)animateHideLogin {
  [UIView beginAnimations:@"HideLogin" context:nil];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(animateHideLoginFinished)];
  [UIView setAnimationBeginsFromCurrentState:YES];
  [UIView setAnimationCurve:UIViewAnimationCurveLinear];
  [UIView setAnimationDuration:0.6]; // Fade out is configurable in seconds (FLOAT)
  [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.window cache:YES];
  [self.window exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
  [UIView commitAnimations];
}

- (void)animateHideLoginFinished {
  [_loginViewController.view removeFromSuperview];
}

- (void)dealloc {
  RELEASE_SAFELY(_loginDataCenter);
  RELEASE_SAFELY(_sessionKey);
  RELEASE_SAFELY(_loginViewController);
  RELEASE_SAFELY(_launcherViewController);
  RELEASE_SAFELY(_facebook);
  RELEASE_SAFELY(_window);
  [super dealloc];
}

@end

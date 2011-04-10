//
//  KupoAppDelegate.m
//  Kupo
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoAppDelegate.h"
#import "Constants.h"
#import "FBConnect.h"
#import "LICoreDataStack.h"
#import "LoginViewController.h"
#import "PlaceViewController.h"
#import "LoginDataCenter.h"

@implementation KupoAppDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;
@synthesize sessionKey = _sessionKey;
@synthesize navigationController = _navigationController;

+ (void)initialize {
  [self setupDefaults];
}

+ (void)setupDefaults {
  if ([self class] == [KupoAppDelegate class]) {
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
  self.window.backgroundColor = FB_COLOR_DARK_GRAY_BLUE;
  
  // Login/Session/Register data center
  [[LoginDataCenter defaultCenter] setDelegate:self];

  // Setup Facebook
  _facebook = [[Facebook alloc] initWithAppId:FB_APP_ID];
  
  _placeViewController = [[PlaceViewController alloc] init];
  
  // NavigationController
  _navigationController = [[UINavigationController alloc] initWithRootViewController:_placeViewController];
  
  // LoginVC
  _loginViewController = [[LoginViewController alloc] init];
  _loginViewController.delegate = self;
  
  [self.window addSubview:_navigationController.view];
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
  /*
   Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
   If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
   */
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
  // Saves changes in the application's managed object context before the application terminates.
  [self saveContext];
}

- (void)saveContext {
  NSError *error = nil;
  NSManagedObjectContext *managedObjectContext = [LICoreDataStack sharedManagedObjectContext];
  if (managedObjectContext != nil) {
    if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
      /*
       Replace this implementation with code to handle the error appropriately.
       
       abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
       */
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
      abort();
    } 
  }
}

#pragma mark -
#pragma mark Login
- (void)tryLogin {
  if (![[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
    if (![_navigationController.modalViewController isEqual:_loginViewController] && _loginViewController != nil) {
      [_navigationController presentModalViewController:_loginViewController animated:NO];
    }
  } else {
    _facebook.accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"];
    _facebook.expirationDate = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookExpirationDate"];
    [self startSession];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadController object:nil];
  }
}

#pragma mark -
#pragma mark LoginDelegate
- (void)kupoDidLogin {
  DLog(@"Kupo Logged In");
  
  // Change login screen to edu walkthru / loading
  
  [self startRegister];
}

- (void)kupoDidLogout {
  // Delete all existing data
  [LICoreDataStack resetPersistentStore];
  [self tryLogin];
}

#pragma mark Session
- (void)startSession {
  // This gets called on subsequent app launches
  [self resetSessionKey];
  [[LoginDataCenter defaultCenter] startSession];
}

- (void)startRegister {
  // This gets called] if it is the first time logging in
  [self resetSessionKey];
  [[LoginDataCenter defaultCenter] startRegister];
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
- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
  
  // Determine if this is register or session
  NSString *requestUrlString = [[operation requestURL] absoluteString];
  if ([requestUrlString rangeOfString:@"register"].location != NSNotFound) {  
    // Kupo server will send user ID, name, and array of friend ids
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
    [[NSUserDefaults standardUserDefaults] setObject:[[[LoginDataCenter defaultCenter] response] valueForKey:@"facebook_id"] forKey:@"facebookId"];
    [[NSUserDefaults standardUserDefaults] setObject:[[[LoginDataCenter defaultCenter] response] valueForKey:@"name"] forKey:@"facebookName"];
    [[NSUserDefaults standardUserDefaults] setObject:[[[LoginDataCenter defaultCenter] response] valueForKey:@"friends"] forKey:@"friends"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Flag place controller to reload after logging in
    _placeViewController.shouldReloadOnAppear = YES;
  }
  
  // Session/Register request finished
  if ([_navigationController.modalViewController isEqual:_loginViewController]) {
    [_navigationController dismissModalViewControllerAnimated:YES];
  }
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
  // Session/Register request failed
  // Show login again
  _loginViewController.loginButton.hidden = NO;
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
  [[LoginDataCenter defaultCenter] setDelegate:nil];
  RELEASE_SAFELY(_sessionKey);
  RELEASE_SAFELY(_loginViewController);
  RELEASE_SAFELY(_placeViewController);
  RELEASE_SAFELY(_navigationController);
  RELEASE_SAFELY(_facebook);
  RELEASE_SAFELY(_window);
  [super dealloc];
}

@end

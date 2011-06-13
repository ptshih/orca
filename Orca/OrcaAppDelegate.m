//
//  OrcaAppDelegate.m
//  Orca
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrcaAppDelegate.h"
#import "Constants.h"
#import "FBConnect.h"
#import "LoginViewController.h"
#import "LauncherViewController.h"
#import "LoginDataCenter.h"
#import "PSImageCache.h"

@implementation OrcaAppDelegate

@synthesize window = _window;
@synthesize facebook = _facebook;
@synthesize sessionKey = _sessionKey;
@synthesize launcherViewController = _launcherViewController;

+ (void)initialize {
  [self setupDefaults];
}

+ (void)setupDefaults {
  if ([self class] == [OrcaAppDelegate class]) {
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

  // We can configure if the imageCache should reside in cache or document directory here
//  [[PSImageCache sharedCache] setCacheDirectory:NSCachesDirectory];
//  [[PSImageCache sharedCache] setCacheDirectory:NSDocumentDirectory];
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"weave-bg.png"]];

  
  // Setup Facebook
  _facebook = [[Facebook alloc] initWithAppId:FB_APP_ID];
  
  // LoginVC
  _loginViewController = [[LoginViewController alloc] init];
  _loginViewController.delegate = self;
  
  _launcherViewController = [[LauncherViewController alloc] init];
  
  [self.window addSubview:_launcherViewController.view];
  [self.window makeKeyAndVisible];
  
  // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
  
  // Handle entry via APNS
  if (launchOptions) {
		NSDictionary *dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary) {
			NSLog(@"Launched from push notification: %@", dictionary);
      if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"]) {
        [self processMessageFromRemoteNotification:dictionary];
      }
		}
	}
  
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
#pragma mark APNS
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  NSLog(@"Received notification while app was active: %@", userInfo);
  [self processMessageFromRemoteNotification:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
	NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)processMessageFromRemoteNotification:(NSDictionary *)userInfo {
  // This method should 
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
- (void)userDidLogin:(NSDictionary *)userInfo {
  DLog(@"User Logged In");
  [self getMe];
}

- (void)userDidLogout {
  // Delete all existing data
  [self tryLogin];
  [PSCoreDataStack resetPersistentStoreCoordinator];
}

- (void)getMe {
  // This is called the first time logging in
  NSURL *meUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/me?fields=id,name,friends&access_token=%@", FB_GRAPH, [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"]]];
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:meUrl];
  request.requestMethod = @"GET";
  request.allowCompressedResponse = YES;
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self serializeMeWithResponse:[[request responseData] JSONValue]];
    [self startDownloadAlbums];
  }];
  [request setFailedBlock:^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutRequested object:nil];
  }];
  
  // Start the Request
  [request startAsynchronous];
}

- (void)serializeMeWithResponse:(id)response {
  NSString *facebookId = [response valueForKey:@"id"];
  NSString *facebookName = [response valueForKey:@"name"];
  NSString *facebookPictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", facebookId];
  NSArray *facebookFriends = [response valueForKey:@"friends"] ? [[response valueForKey:@"friends"] valueForKey:@"data"] : [NSArray array];
  
  NSMutableDictionary *friendsDict = [NSMutableDictionary dictionary];
  for (NSDictionary *friend in facebookFriends) {
    [friendsDict setValue:[friend valueForKey:@"name"] forKey:[friend valueForKey:@"id"]];
  }
  
  // Set UserDefaults
  [[NSUserDefaults standardUserDefaults] setObject:facebookId forKey:@"facebookId"];
  [[NSUserDefaults standardUserDefaults] setObject:facebookName forKey:@"facebookName"];
  [[NSUserDefaults standardUserDefaults] setObject:facebookPictureUrl forKey:@"facebookPictureUrl"];
  [[NSUserDefaults standardUserDefaults] setObject:friendsDict forKey:@"facebookFriends"];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getFriends {
  // This is called subsequent app launches when already logged in
  NSURL *friendsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/me/friends?access_token=%@", FB_GRAPH, [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"]]];
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:friendsUrl];
  request.requestMethod = @"GET";
  request.allowCompressedResponse = YES;
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self serializeFriendsWithResponse:[[request responseData] JSONValue]];
    [self startDownloadAlbums];
  }];
  [request setFailedBlock:^{
    [self startDownloadAlbums];
  }];
  
  // Start the Request
  [request startAsynchronous];
}

- (void)serializeFriendsWithResponse:(id)response {
  NSArray *facebookFriends = [response valueForKey:@"data"] ? [response valueForKey:@"data"] : [NSArray array];
  
  NSDictionary *existingFriends = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"facebookFriends"];
  NSMutableDictionary *friendsDict = existingFriends ? [NSMutableDictionary dictionaryWithDictionary:existingFriends] : [NSMutableDictionary dictionary];
  
  NSMutableArray *newFriendIds = [NSMutableArray array];
  
  for (NSDictionary *friend in facebookFriends) {
    NSString *friendId = [friend valueForKey:@"id"];
    if (![friendsDict valueForKey:friendId]) {
      [newFriendIds addObject:friendId];
    }
    [friendsDict setValue:[friend valueForKey:@"name"] forKey:friendId];
  }
  
  [[NSUserDefaults standardUserDefaults] setObject:friendsDict forKey:@"facebookFriends"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  if ([newFriendIds count] > 0) {
//    [[AlbumDataCenter defaultCenter] getAlbumsForFriendIds:newFriendIds];
  }
}

- (void)startDownloadAlbums {
//  [[AlbumDataCenter defaultCenter] getAlbums];
  
#warning debug bypass
  [self dataCenterDidFinish:nil withResponse:nil];
}

#pragma mark Session
- (void)startSession {
  // This gets called on subsequent app launches
  [self resetSessionKey];
  [self getFriends];
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
  // Session/Register request finished
  if ([_launcherViewController.modalViewController isEqual:_loginViewController]) {
    [_launcherViewController dismissModalViewControllerAnimated:YES];
  }
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  // Show login again
//  [_loginViewController logout];
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
  RELEASE_SAFELY(_sessionKey);
  RELEASE_SAFELY(_loginViewController);
  RELEASE_SAFELY(_launcherViewController);
  RELEASE_SAFELY(_facebook);
  RELEASE_SAFELY(_window);
  [super dealloc];
}

@end

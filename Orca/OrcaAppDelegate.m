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
#import "ASIS3Request.h"

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
  
  // AWS S3
  [ASIS3Request setSharedAccessKey:@"AKIAJRFSK3RWQ7XLGNFA"];
  [ASIS3Request setSharedSecretAccessKey:@"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"];
  
  // Application Lifecycle States
  _applicationWasResigned = NO;
  _applicationWasBackgrounded = NO;
  
  NSLog(@"fonts: %@",[UIFont familyNames]);

  // We can configure if the imageCache should reside in cache or document directory here
//  [[PSImageCache sharedCache] setCacheDirectory:NSCachesDirectory];
//  [[PSImageCache sharedCache] setCacheDirectory:NSDocumentDirectory];
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-weave.png"]];

  UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"texture-spotlight.png"]];
  backgroundView.frame = self.window.bounds;
  [self.window insertSubview:backgroundView atIndex:0];
  [backgroundView release];
  
  // Setup Facebook
  _facebook = [[Facebook alloc] initWithAppId:FB_APP_ID];
  
  // LoginVC
  _loginViewController = [[LoginViewController alloc] init];
  _loginViewController.delegate = self;
  
  _launcherViewController = [[LauncherViewController alloc] init];
  
  [self.window addSubview:_launcherViewController.view];
  [self.window makeKeyAndVisible];
  
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
  _applicationWasResigned = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  _applicationWasBackgrounded = YES;
  
  // Flush NSUserDefaults just in case
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Reload all controllers when entering foreground
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadPodController object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  if (_applicationWasResigned) {
    _applicationWasResigned = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadPodController object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
  }
  
  if (_applicationWasBackgrounded) {
    _applicationWasBackgrounded = NO;
    
    // UNUSED
  }
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Flush NSUserDefaults just in case
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark APNS
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
  NSLog(@"Received notification while app was active: %@", userInfo);
  [self processMessageFromRemoteNotification:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
  NSString *newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSLog(@"My token is: %@", newToken);
  
  [self startRegisterPushWithDeviceToken:newToken];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)processMessageFromRemoteNotification:(NSDictionary *)userInfo {
  // This method should 
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadPodController object:nil];
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadMessageController object:nil];
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
  NSURL *meUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/me?fields=id,name,first_name,last_name,friends&access_token=%@", FB_GRAPH, [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"]]];
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:meUrl];
  request.requestMethod = @"GET";
  request.allowCompressedResponse = YES;
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self serializeMeWithResponse:[[request responseData] JSONValue]];
    [self startRegister];
  }];
  [request setFailedBlock:^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutRequested object:nil];
  }];
  
  // Start the Request
  [[PSNetworkQueue sharedQueue] addOperation:request];
}

- (void)serializeMeWithResponse:(id)response {
  NSString *facebookId = [response valueForKey:@"id"];
  NSString *facebookName = [response valueForKey:@"name"];
  NSString *facebookFirstName = [response valueForKey:@"first_name"];
  NSString *facebookLastName = [response valueForKey:@"last_name"];
  NSString *facebookPictureUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=square", facebookId];
  NSArray *facebookFriends = [response valueForKey:@"friends"] ? [[response valueForKey:@"friends"] valueForKey:@"data"] : [NSArray array];
  
  NSMutableDictionary *friendsDict = [NSMutableDictionary dictionary];
  for (NSDictionary *friend in facebookFriends) {
    [friendsDict setValue:[friend valueForKey:@"name"] forKey:[friend valueForKey:@"id"]];
  }
  
  // Set UserDefaults
  [[NSUserDefaults standardUserDefaults] setObject:facebookId forKey:@"facebookId"];
  [[NSUserDefaults standardUserDefaults] setObject:facebookName forKey:@"facebookName"];
  [[NSUserDefaults standardUserDefaults] setObject:facebookFirstName forKey:@"facebookFirstName"];
  [[NSUserDefaults standardUserDefaults] setObject:facebookLastName forKey:@"facebookLastName"];
  [[NSUserDefaults standardUserDefaults] setObject:facebookPictureUrl forKey:@"facebookPictureUrl"];
  [[NSUserDefaults standardUserDefaults] setObject:friendsDict forKey:@"facebookFriends"];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark Session
- (void)startSession {  
#warning disable sessions
  return;
  
  // This gets called on subsequent app launches
  [self resetSessionKey];

  // Send a call home to our server, fire and forget
  // This sends a call home to our server to register the user and get an access_token
  NSURL *sessionURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/session", API_BASE_URL]];
  
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:sessionURL];
  request.requestMethod = @"GET";
  
  // Accept JSON
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Metrics Headers
  [request addRequestHeader:@"X-UDID" value:[[UIDevice currentDevice] uniqueIdentifier]];
  [request addRequestHeader:@"X-Device-Model" value:[[UIDevice currentDevice] model]];
  [request addRequestHeader:@"X-App-Version" value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
  [request addRequestHeader:@"X-System-Name" value:[[UIDevice currentDevice] systemName]];
  [request addRequestHeader:@"X-System-Version" value:[[UIDevice currentDevice] systemVersion]];
  [request addRequestHeader:@"X-User-Language" value:USER_LANGUAGE];
  [request addRequestHeader:@"X-User-Locale" value:USER_LOCALE];
  if (APP_DELEGATE.sessionKey) [request addRequestHeader:@"X-Session-Key" value:APP_DELEGATE.sessionKey];
  
  // Request Completion Block
  [request setCompletionBlock:^{
  }];
  
  [request setFailedBlock:^{
  }];
  
  // Start the Request
  [[PSNetworkQueue sharedQueue] addOperation:request];
}

#pragma mark Register
- (void)startRegister {
  // This sends a call home to our server to register the user and get an access_token
  NSURL *registerURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/register", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"facebookId"] forKey:@"facebook_id"];
  [params setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"facebookName"] forKey:@"facebook_name"];
  [params setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"facebookFirstName"] forKey:@"facebook_first_name"];
  [params setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"facebookLastName"] forKey:@"facebook_last_name"];
  [params setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"] forKey:@"facebook_access_token"];
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:registerURL];
  request.requestMethod = @"POST";
  request.postBody = [[LoginDataCenter defaultCenter] buildRequestParamsData:params];
  request.postLength = [request.postBody length];
  
  // Accept JSON
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Metrics Headers
  [request addRequestHeader:@"X-UDID" value:[[UIDevice currentDevice] uniqueIdentifier]];
  [request addRequestHeader:@"X-Device-Model" value:[[UIDevice currentDevice] model]];
  [request addRequestHeader:@"X-App-Version" value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
  [request addRequestHeader:@"X-System-Name" value:[[UIDevice currentDevice] systemName]];
  [request addRequestHeader:@"X-System-Version" value:[[UIDevice currentDevice] systemVersion]];
  [request addRequestHeader:@"X-User-Language" value:USER_LANGUAGE];
  [request addRequestHeader:@"X-User-Locale" value:USER_LOCALE];
  
  // Request Completion Block
  [request setCompletionBlock:^{
    // Read the response access_token
    id response = [[request responseData] JSONValue];
    VLog(@"got access token from register: %@", response);
    [[NSUserDefaults standardUserDefaults] setValue:[response valueForKey:@"access_token"] forKey:@"accessToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self launchFinished];
  }];
  
  [request setFailedBlock:^{
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutRequested object:nil];
  }];
  
  // Start the Request
  [[PSNetworkQueue sharedQueue] addOperation:request];
}

- (void)launchFinished {
  // Let the device know we want to receive push notifications
  [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
  
  // UIRemoteNotificationTypeBadge
  
  if ([_launcherViewController.modalViewController isEqual:_loginViewController]) {
    [_launcherViewController dismissModalViewControllerAnimated:YES];
  }
}

#pragma mark Register Push
- (void)startRegisterPushWithDeviceToken:(NSString *)deviceToken {
  // This sends a call home to our server to register the user's device for push
  NSURL *registerPushURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/registerpush", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setValue:deviceToken forKey:@"device_token"];
  
  // Send access_token as a parameter if exists
  NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
  if (accessToken) {
    [params setValue:accessToken forKey:@"access_token"];
  }
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:registerPushURL];
  request.requestMethod = @"POST";
  request.postBody = [[LoginDataCenter defaultCenter] buildRequestParamsData:params];
  request.postLength = [request.postBody length];
  
  // Accept JSON
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Metrics Headers
  [request addRequestHeader:@"X-UDID" value:[[UIDevice currentDevice] uniqueIdentifier]];
  [request addRequestHeader:@"X-Device-Model" value:[[UIDevice currentDevice] model]];
  [request addRequestHeader:@"X-App-Version" value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
  [request addRequestHeader:@"X-System-Name" value:[[UIDevice currentDevice] systemName]];
  [request addRequestHeader:@"X-System-Version" value:[[UIDevice currentDevice] systemVersion]];
  [request addRequestHeader:@"X-User-Language" value:USER_LANGUAGE];
  [request addRequestHeader:@"X-User-Locale" value:USER_LOCALE];
  
  // Request Completion Block
  [request setCompletionBlock:^{
  }];
  
  [request setFailedBlock:^{
  }];
  
  // Start the Request
  [[PSNetworkQueue sharedQueue] addOperation:request];
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

- (void)dealloc {
  RELEASE_SAFELY(_sessionKey);
  RELEASE_SAFELY(_loginViewController);
  RELEASE_SAFELY(_launcherViewController);
  RELEASE_SAFELY(_facebook);
  RELEASE_SAFELY(_window);
  [super dealloc];
}

@end

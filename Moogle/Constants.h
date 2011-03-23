/*
 *  Constants.h
 *  Moogle
 *
 *  Created by Peter Shih on 10/8/10.
 *  Copyright 2010 Seven Minute Apps. All rights reserved.
 *
 */

#import "MoogleAppDelegate.h"
#import "UIView+Additions.h"
#import "NSDate+HumanInterval.h"

#define USE_ROUNDED_CORNERS

#ifdef __APPLE__
  #include "TargetConditionals.h"
#endif

//#define CLEAR_ALL_CACHED_DATA_ON_WARNING

#define USER_LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0]
#define USER_LOCALE [[NSLocale autoupdatingCurrentLocale] localeIdentifier]

// Notifications
#define kLocationAcquired @"LocationAcquired"

// API Version
#define API_VERSION @"v1"

#define NUMBER_OF_CARDS 4
#define CARD_WIDTH 320.0
#define CARD_HEIGHT 411.0
#define CARD_HEIGHT_WITH_NAV 367.0

// If this is defined, we will hit the staging server instead of prod
// #define STAGING

#if TARGET_IPHONE_SIMULATOR
  #define STAGING
  #define USE_LOCALHOST
#endif

#ifdef STAGING
  #ifdef USE_LOCALHOST
    #define MOOGLE_BASE_URL @"http://localhost:3000"
  #else
    #define MOOGLE_BASE_URL @"http://moogle-staging.heroku.com"
  #endif
#else
  #define MOOGLE_BASE_URL @"http://moogle.heroku.com"
#endif

#define MOOGLE_TERMS_URL @"http://www.sevenminuteapps.com/terms"
#define MOOGLE_PRIVACY_URL @"http://www.sevenminuteapps.com/privacy"

#define FB_GRAPH_FRIENDS @"https://graph.facebook.com/me/friends"
#define FB_GRAPH_ME @"https://graph.facebook.com/me"

// Moogle App
#define FB_APP_ID @"132514440148709"
#define FB_APP_SECRET @"925b0a280e685631acf466dfea13b154"
#define FB_PERMISSIONS [NSArray arrayWithObjects:@"offline_access", @"user_checkins", @"friends_checkins", @"publish_checkins", @"read_friendlists", @"manage_friendlists", nil]
#define FB_PARAMS @"id,first_name,last_name,name,gender,locale"
#define FB_CHECKIN_PARAMS @"id,from,tags,place,message,application,created_time"
#define FB_AUTHORIZE_URL @"https://m.facebook.com/dialog/oauth"
//#define FB_AUTHORIZE_URL @"https://graph.facebook.com/oauth/authorize"

// #define FB_PERMISSIONS [NSArray arrayWithObjects:@"offline_access",@"user_photos",@"friends_photos",@"user_education_history",@"friends_education_history",@"user_work_history",@"friends_work_history",nil]

// #define FB_EXPIRE_TOKEN // if defined, will send a request to FB to expire a user's token

// Unused, FB doesn't seem to return these
// interested_in
// meeting_for

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

// ERROR STRINGS
#define MOOGLE_LOGOUT_ALERT @"Are you sure you want to logout?"
#define FM_NETWORK_ERROR @"Moogle has encountered a network error. Please check your network connection and try again."

//#define OAUTH_TOKEN @"151779758183785|2.mlbpS5_RD5Ao_hTpWQtBVg__.3600.1289080800-548430564|es6q1fc8hb7pSL2UpwFegiF1F8c"

// FB DARK BLUE 51/78/141
// FB LIGHT BLUE 161/176/206
#define FB_COLOR_VERY_LIGHT_BLUE RGBCOLOR(220.0,225.0,235.0)
#define FB_COLOR_LIGHT_BLUE RGBCOLOR(161.0,176.0,206.0)
#define FB_COLOR_DARK_BLUE RGBCOLOR(51.0,78.0,141.0)
#define LIGHT_GRAY RGBCOLOR(247.0,247.0,247.0)
#define FILTER_COLOR_BLUE RGBCOLOR(79.0,92.0,117.0)
#define VERY_LIGHT_GRAY RGBCOLOR(226.0,231.0,237.0)
#define GRAY_COLOR RGBCOLOR(87.0,108.0,137.0)
#define SEPARATOR_COLOR RGBCOLOR(180.0,180.0,180.0)
#define MOOGLE_BLUE_COLOR RGBCOLOR(45.0,147.0,204.0)

#define RGBCOLOR(R,G,B) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define RGBACOLOR(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

// App Delegate Macro
#define APP_DELEGATE ((MoogleAppDelegate *)[[UIApplication sharedApplication] delegate])

// Logging Macros
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

//#define VERBOSE_DEBUG
#ifdef VERBOSE_DEBUG
#define VLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define VLog(...)
#endif

// ALog always displays output regardless of the DEBUG setting
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

// Safe releases
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

// Release a CoreFoundation object safely.
#define RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }

// Detect Device Type
static BOOL isDeviceIPad() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    return YES; 
  }
#endif
  return NO;
}
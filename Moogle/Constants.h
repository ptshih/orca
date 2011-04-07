/*
 *  Constants.h
 *  Moogle
 *
 *  Created by Peter Shih on 10/8/10.
 *  Copyright 2010 Seven Minute Apps. All rights reserved.
 *
 */

#import "MoogleAppDelegate.h"
#import "UIScreen+ConvertRect.h"
#import "UIView+Additions.h"
#import "UILabel+SizeToFitWidth.h"
#import "NSDate+HumanInterval.h"

#ifdef __APPLE__
  #include "TargetConditionals.h"
#endif

//#define CLEAR_ALL_CACHED_DATA_ON_WARNING

#define USER_LANGUAGE [[NSLocale preferredLanguages] objectAtIndex:0]
#define USER_LOCALE [[NSLocale autoupdatingCurrentLocale] localeIdentifier]

// Notifications
#define kLocationAcquired @"LocationAcquired"
#define kLogoutRequested @"LogoutRequested"
#define kCoreDataDidReset @"CoreDataDidReset"
#define kComposeDidFinish @"ComposeDidFinish"
#define kComposeDidFail @"ComposeDidFail"

// Cards
#define NUM_CARDS 2
#define CARD_WIDTH 320.0
#define CARD_HEIGHT 460.0
#define CARD_HEIGHT_WITH_NAV 416.0

#define RADIANS(degrees) ((degrees * M_PI) / 180.0)

// Facebook
#define FB_APP_ID @"132514440148709"
#define FB_APP_SECRET @"925b0a280e685631acf466dfea13b154"
#define FB_PERMISSIONS [NSArray arrayWithObjects:@"offline_access", @"user_checkins", @"friends_checkins", @"publish_checkins", nil]
#define FB_PARAMS @"id,first_name,last_name,name,gender,locale"
#define FB_CHECKIN_PARAMS @"id,from,tags,place,message,application,created_time"

// ERROR STRINGS
#define MOOGLE_LOGOUT_ALERT @"Are you sure you want to logout?"
#define FM_NETWORK_ERROR @"Moogle has encountered a network error. Please check your network connection and try again."

// Colors
// CELLS
#define CELL_BLACK_COLOR [UIColor blackColor]
#define CELL_GRAY_BLUE_COLOR RGBCOLOR(62,76,102)
#define CELL_BLUE_COLOR RGBCOLOR(59.0,89.0,152.0)
#define CELL_DARK_BLUE_COLOR RGBCOLOR(51.0,78.0,141.0)

// NAV
#define NAV_COLOR_DARK_GREEN RGBCOLOR(62,76,102)

// FB DARK BLUE 51/78/141
// FB LIGHT BLUE 161/176/206
#define FB_COLOR_VERY_LIGHT_BLUE RGBCOLOR(220.0,225.0,235.0)
#define FB_COLOR_LIGHT_BLUE RGBCOLOR(161.0,176.0,206.0)
#define FB_COLOR_DARK_BLUE RGBCOLOR(51.0,78.0,141.0)
#define LIGHT_GRAY RGBCOLOR(247.0,247.0,247.0)
#define VERY_LIGHT_GRAY RGBCOLOR(226.0,231.0,237.0)
#define GRAY_COLOR RGBCOLOR(87.0,108.0,137.0)

#define SEPARATOR_COLOR RGBCOLOR(180.0,180.0,180.0)

#define MOOGLE_BLUE_COLOR RGBCOLOR(45.0,147.0,204.0)
#define FB_BLUE_COLOR RGBCOLOR(59.0,89.0,152.0)
#define FB_COLOR_DARK_GRAY_BLUE RGBCOLOR(79.0,92.0,117.0)

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
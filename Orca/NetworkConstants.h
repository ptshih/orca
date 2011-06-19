//
//  NetworkConstants.h
//  Orca
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

// HTTP Terms
#define GET @"GET"
#define POST @"POST"
#define PUT @"PUT"
#define DELETE @"DELETE"

// API Version
#define API_VERSION @"v1"

#define SEND_METRICS_HEADERS

// If this is defined, we will hit the staging server instead of prod
//#define STAGING

#if TARGET_IPHONE_SIMULATOR
  #define STAGING
  #define USE_LOCALHOST
#endif

#ifdef STAGING
  #ifdef USE_LOCALHOST
    #define API_BASE_URL [NSString stringWithFormat:@"http://localhost:3000/%@", API_VERSION]
  #else
    #define API_BASE_URL [NSString stringWithFormat:@"http://orcapods.heroku.com/%@", API_VERSION]
  #endif
#else
  #define API_BASE_URL [NSString stringWithFormat:@"http://orcapods.heroku.com/%@", API_VERSION]
#endif

// API Endpoints
// #define TEST // enable this to hit test APIs

#ifdef TEST
  #define PODS_ENDPOINT @"pods_test"
  #define MESSAGES_ENDPOINT @"messages_test"
#else
  #define PODS_ENDPOINT @"pods"
  #define MESSAGES_ENDPOINT @"messages"
#endif

// AWS S3
#define S3_KEY @"AKIAJRFSK3RWQ7XLGNFA"
#define S3_SECRET_KEY @"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"
#define S3_URL @"http://s3.amazonaws.com"
#define S3_BUCKET @"orcapods"
#define S3_BUCKET_URL @"http://orcapods.s3.amazonaws.com"

#define S3_PHOTOS_URL @"http://s3.amazonaws.com/scrapboard/kupos/photos"
#define S3_VIDEOS_URL @"http://s3.amazonaws.com/scrapboard/kupos/videos"

// Seven Minute Apps
#define TERMS_URL @"http://www.sevenminuteapps.com/terms"
#define PRIVACY_URL @"http://www.sevenminuteapps.com/privacy"

// Facebook
#define FB_AUTHORIZE_URL @"https://m.facebook.com/dialog/oauth"
#define FB_GRAPH @"https://graph.facebook.com"

#define FB_ALBUMS [NSString stringWithFormat:@"%@/me/albums", FB_GRAPH]

// #define FB_PERMISSIONS [NSArray arrayWithObjects:@"offline_access",@"user_photos",@"friends_photos",@"user_education_history",@"friends_education_history",@"user_work_history",@"friends_work_history",nil]

// #define FB_EXPIRE_TOKEN // if defined, will send a request to FB to expire a user's token

// Unused, FB doesn't seem to return these
// interested_in
// meeting_for
//
//  PSDataCenter.h
//  Orca
//
//  Created by Peter Shih on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSObject.h"
#import "PSDataCenterDelegate.h"
#import "ASIHTTPRequest.h"
#import "ASIS3Request.h"
#import "ASIS3ObjectRequest.h"
#import "ASIFormDataRequest.h"
#import "PSNetworkQueue.h"
#import "JSON.h"
#import "JSONKit.h"
#import "PSCoreDataStack.h"
#import "NetworkConstants.h"

#define SINCE_SAFETY_NET 300 // 5 minutes

@interface PSDataCenter : PSObject <PSDataCenterDelegate> {
  id <PSDataCenterDelegate> _delegate;
}

@property (nonatomic, assign) id <PSDataCenterDelegate> delegate;

/**
 Send network operation to server (GET/POST)
 By default this will set all required headers
 
 @param url api endpoint to send request (required)
 @param method http method (default GET) (optional)
 @param headers
 @param params
 @param userInfo
 */
- (void)sendRequestWithURL:(NSURL *)url andMethod:(NSString *)method andHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo;

/**
 Send network request with a photo, FORM DATA POST
 */
- (void)sendFormRequestWithURL:(NSURL *)url andHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params andFile:(NSDictionary *)file andUserInfo:(NSDictionary *)userInfo;

- (void)sendFacebookBatchRequestWithParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo;

/**
 ASI S3 Request
 */
- (void)sendS3RequestWithData:(NSData *)data forBucket:(NSString *)bucket forKey:(NSString *)key andUserInfo:(NSDictionary *)userInfo;

/**
 AWS S3
 */
- (void)sendAWSS3RequestWithData:(NSData *)data andUserInfo:(NSDictionary *)userInfo;

// Subclass should Implement AND call super's implementation
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request;
- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request;

/**
 Core Data Serialization Methods
 */
//- (void)serializeResponseArray:(NSArray *)array forEntityName:(NSString *)entityName andUniqueKey:(NSString *)uniqueKey inContext:(NSManagedObjectContext *)context;

/**
 Helpers to build request params string
 */
- (NSString *)buildRequestParamsString:(NSDictionary *)params;
- (NSMutableData *)buildRequestParamsData:(NSDictionary *)params;

// AWS Signature
- (NSString *)signedAWSAuthHeaderWithRequest:(ASIHTTPRequest *)request;

@end

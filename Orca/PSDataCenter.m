//
//  PSDataCenter.m
//  Orca
//
//  Created by Peter Shih on 2/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PSDataCenter.h"

@interface PSDataCenter (Private)

- (id)sanitizeResponse:(NSData *)responseData;
- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary forKeys:(NSArray *)keys;
- (NSArray *)sanitizeArray:(NSArray *)array;

@end

@implementation PSDataCenter

@synthesize delegate = _delegate;
@synthesize pendingRequests = _pendingRequests;

- (id)init {
  self = [super init];
  if (self) {
    _pendingRequests = [[NSMutableArray alloc] initWithCapacity:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(coreDataDidReset) name:kCoreDataDidReset object:nil];
  }
  return self;
}

- (void)coreDataDidReset {
  for (ASIHTTPRequest *request in _pendingRequests) {
    [request clearDelegatesAndCancel];
  }
  [_pendingRequests removeAllObjects];
}

#pragma mark -
#pragma mark Serialize
- (id)sanitizeResponse:(NSData *)responseData {
  // Serialize the response
  id rawResponse = [responseData JSONValue];
  id response = nil;
  
  // We should sanitize the response
  if ([rawResponse isKindOfClass:[NSArray class]]) {
    response = [self sanitizeArray:rawResponse];
  } else if ([rawResponse isKindOfClass:[NSDictionary class]]) {
    response = [self sanitizeDictionary:rawResponse forKeys:[rawResponse allKeys]];
  } else {
    // Throw an assertion, why is it not a dictionary or an array???
    DLog(@"### ERROR IN DATA CENTER, RESPONSE IS NEITHER AN ARRAY NOR A DICTIONARY");
  }
  
  if (response) {
    return response;
  } else {
    return nil;
  }
}

#pragma mark -
#pragma mark Send Operation
- (void)sendFacebookBatchRequestWithParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo {
  // Read any optional params
  NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
  
  // Send access_token as a parameter if exists
  NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"];
  if (accessToken) {
    [requestParams setValue:accessToken forKey:@"access_token"];
  }
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:FB_GRAPH]];
  request.requestMethod = @"POST";
  
  // Allow GZIP
  request.allowCompressedResponse = YES;
  
  // Request userInfo
  request.userInfo = userInfo;
  
  // POST parameters
  request.postBody = [self buildRequestParamsData:requestParams];
  request.postLength = [request.postBody length];
  
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self dataCenterRequestFinished:request];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObject:request];
  }];
  [request setFailedBlock:^{
    [self dataCenterRequestFailed:request];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObject:request];
  }];
  
  // Start the Request
  [_pendingRequests addObject:request];
  [request startAsynchronous];
}

- (void)sendRequestWithURL:(NSURL *)url andMethod:(NSString *)method andHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params andUserInfo:(NSDictionary *)userInfo {
  // Read any optional params
  NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
  
  // Send access_token as a parameter if exists
  NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
  if (accessToken) {
    [requestParams setValue:accessToken forKey:@"access_token"];
    DLog(@"Sending a request to url: %@ with access_token: %@", url, accessToken);
  } else {
    DLog(@"WARNING, NO ACCESS TOKEN in userDefaults, NOT SENDING ONE: %@", url);
  }
  
  // GET parameters
  if ([method isEqualToString:GET]) {
    url = [NSURL URLWithString:[NSString stringWithFormat:@"?%@", [self buildRequestParamsString:requestParams]] relativeToURL:url];
  }
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
  request.requestMethod = method;
  
  // Allow GZIP
  request.allowCompressedResponse = YES;
  
  // Request userInfo
  request.userInfo = userInfo;
  
  // POST parameters
  if ([method isEqualToString:POST]) {
    request.postBody = [self buildRequestParamsData:requestParams];
    request.postLength = [request.postBody length];
  }
  
  // Add Headers
#ifdef SEND_METRICS_HEADERS
  [request addRequestHeader:@"X-UDID" value:[[UIDevice currentDevice] uniqueIdentifier]];
  [request addRequestHeader:@"X-Device-Model" value:[[UIDevice currentDevice] model]];
  [request addRequestHeader:@"X-App-Version" value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
  [request addRequestHeader:@"X-System-Name" value:[[UIDevice currentDevice] systemName]];
  [request addRequestHeader:@"X-System-Version" value:[[UIDevice currentDevice] systemVersion]];
  [request addRequestHeader:@"X-User-Language" value:USER_LANGUAGE];
  [request addRequestHeader:@"X-User-Locale" value:USER_LOCALE];
  if (APP_DELEGATE.sessionKey) [request addRequestHeader:@"X-Session-Key" value:APP_DELEGATE.sessionKey];
#endif
  
  // Build Custom Headers if exists
  if (headers) {
    NSArray *allKeys = [headers allKeys];
    NSArray *allValues = [headers allValues];
    for (int i = 0; i < [headers count]; i++) {
      // NOTE: should probably type transform coerce in the future
      [request addRequestHeader:[allKeys objectAtIndex:i] value:[allValues objectAtIndex:i]];
    }
  }
  
  // HTTP Accept
  //  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self dataCenterRequestFinished:request];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObject:request];
  }];
  [request setFailedBlock:^{
    [self dataCenterRequestFailed:request];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObject:request];
  }];
  
  // Start the Request
  [_pendingRequests addObject:request];
  [request startAsynchronous];
}

- (void)sendFormRequestWithURL:(NSURL *)url andHeaders:(NSDictionary *)headers andParams:(NSDictionary *)params andFile:(NSDictionary *)file andUserInfo:(NSDictionary *)userInfo {
  NSMutableDictionary *requestParams = [NSMutableDictionary dictionaryWithDictionary:params];
  
  // Send access_token as a parameter if exists
  NSString *accessToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"accessToken"];
  if (accessToken) {
    [requestParams setValue:accessToken forKey:@"access_token"];
  }
  
  __block ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
  request.requestMethod = POST;
  [request setShouldContinueWhenAppEntersBackground:YES];
  
  // Allow GZIP
  request.allowCompressedResponse = YES;
  
  // Request userInfo
  request.userInfo = userInfo;
  
  // POST body
  // Build Params if exists
  if (requestParams) {
    NSArray *allKeys = [requestParams allKeys];
    NSArray *allValues = [requestParams allValues];
    for (int i = 0; i < [requestParams count]; i++) {
      [request setPostValue:[allValues objectAtIndex:i] forKey:[allKeys objectAtIndex:i]];
    }
  }
  
  // POST file
  [request setData:[file objectForKey:@"fileData"] withFileName:[file objectForKey:@"fileName"] andContentType:[file objectForKey:@"fileContentType"] forKey:[file objectForKey:@"fileKey"]];
  
  // Add Headers
  [request addRequestHeader:@"X-UDID" value:[[UIDevice currentDevice] uniqueIdentifier]];
  [request addRequestHeader:@"X-Device-Model" value:[[UIDevice currentDevice] model]];
  [request addRequestHeader:@"X-App-Version" value:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
  [request addRequestHeader:@"X-System-Name" value:[[UIDevice currentDevice] systemName]];
  [request addRequestHeader:@"X-System-Version" value:[[UIDevice currentDevice] systemVersion]];
  [request addRequestHeader:@"X-User-Language" value:USER_LANGUAGE];
  [request addRequestHeader:@"X-User-Locale" value:USER_LOCALE];
  if (APP_DELEGATE.sessionKey) [request addRequestHeader:@"X-Session-Key" value:APP_DELEGATE.sessionKey];
  
  // Build Custom Headers if exists
  if (headers) {
    NSArray *allKeys = [headers allKeys];
    NSArray *allValues = [headers allValues];
    for (int i = 0; i < [headers count]; i++) {
      // NOTE: should probably type transform coerce in the future
      [request addRequestHeader:[allKeys objectAtIndex:i] value:[allValues objectAtIndex:i]];
    }
  }
  
  // HTTP Accept
  //  [request addRequestHeader:@"Content-Type" value:@"application/json"];
  [request addRequestHeader:@"Accept" value:@"application/json"];
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self dataCenterRequestFinished:request];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObject:request];
  }];
  [request setFailedBlock:^{
    [self dataCenterRequestFailed:request];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObject:request];
  }];
  
  // Start the Request
  [_pendingRequests addObject:request];
  [request startAsynchronous];
}

- (void)sendAWSS3RequestWithData:(NSData *)data andUserInfo:(NSDictionary *)userInfo {
  NSString *sequence = [userInfo objectForKey:@"sequence"];
  NSString *resource = [NSString stringWithFormat:@"%@/%@.jpg", S3_BUCKET, sequence];
  NSURL *s3URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", S3_URL, resource]];
  
  __block ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:s3URL];
  request.requestMethod = PUT;
  [request setShouldContinueWhenAppEntersBackground:YES];
  
  // Set AWS Headers
  NSString *contentMD5 = [data base64md5String];
  [request addRequestHeader:@"Content-MD5" value:contentMD5];
  [request addRequestHeader:@"Content-Type" value:@"image/jpeg"];
  [request addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", [data length]]];
  [request addRequestHeader:@"Date" value:[[NSDate date] stringWithAWSRequestFormat]];
  [request addRequestHeader:@"x-amz-acl" value:@"public-read"];

  // Authorization header LAST
  NSString *authorization = [NSString stringWithFormat:@"AWS %@:%@", S3_KEY, [self signedAWSAuthHeaderWithRequest:request]];
  [request addRequestHeader:@"Authorization" value:authorization];
  
  
  // POST parameters
  request.postBody = [NSMutableData dataWithData:data];
  request.postLength = [request.postBody length];
  
  // Request userInfo
  request.userInfo = userInfo;
  
  // Request Completion Block
  [request setCompletionBlock:^{
    [self dataCenterRequestFinished:request];
    // No need to notify, we've already faked the cache
//    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageCellReloadPhoto object:nil userInfo:[NSDictionary dictionaryWithObject:sequence forKey:@"sequence"]];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObject:request];
  }];
  [request setFailedBlock:^{
    [self dataCenterRequestFailed:request];
    
    // Remove request from pendingRequests
    [_pendingRequests removeObject:request];
  }];
  
  // Start the Request
  [_pendingRequests addObject:request];
  [request startAsynchronous];
}

#pragma mark -
#pragma mark Request Finished/Failed
- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request {
  // subclass should implement
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request {
  // subclass should implement
  DLog(@"Request failed with error: %@", [[request error] localizedDescription]);
}

#pragma mark -
#pragma mark PSParserStackDelegate
- (void)parseFinishedWithResponse:(id)response andUserInfo:(NSDictionary *)userInfo {
  // subclass should implement
}

#pragma mark -
#pragma mark Private Convenience Methods
- (NSArray *)sanitizeArray:(NSArray *)array {
  NSMutableArray *sanitizedArray = [NSMutableArray array];
  
  // Loop thru all dictionaries in the array
  NSDictionary *sanitizedDictionary = nil;
  for (id value in array) {
    if ([value isKindOfClass:[NSDictionary class]]) {
      sanitizedDictionary = [self sanitizeDictionary:value forKeys:[value allKeys]];
      [sanitizedArray addObject:sanitizedDictionary];
    } else {
      [sanitizedArray addObject:value];
    }
  }
  
  return sanitizedArray;
}

- (NSDictionary *)sanitizeDictionary:(NSDictionary *)dictionary forKeys:(NSArray *)keys {
  NSMutableDictionary *sanitizedDictionary = [NSMutableDictionary dictionary];
  
  // Loop thru all keys we expect to get and remove any keys with nil values
  NSString *value = nil;
  for (NSString *key in keys) {
    value = [dictionary valueForKey:key];
    
    if ([value notNil]) {
      if ([value isKindOfClass:[NSArray class]]) {
        [sanitizedDictionary setValue:[self sanitizeArray:(NSArray *)value] forKey:key];
      } else if ([value isKindOfClass:[NSDictionary class]]) {
        [sanitizedDictionary setValue:[self sanitizeDictionary:(NSDictionary *)value forKeys:[(NSDictionary *)value allKeys]] forKey:key];
      } else {
        [sanitizedDictionary setValue:value forKey:key];
      }
    }
  }
  
  return sanitizedDictionary;
}

- (NSString *)buildRequestParamsString:(NSDictionary *)params {
  if (!params) return nil;
  
  NSMutableString *encodedParameterPairs = [NSMutableString string];
  
  NSArray *allKeys = [params allKeys];
  NSArray *allValues = [params allValues];
  
  for (int i = 0; i < [params count]; i++) {
    [encodedParameterPairs appendFormat:@"%@=%@", [[allKeys objectAtIndex:i] stringByURLEncoding], [[allValues objectAtIndex:i] stringByURLEncoding]];
    if (i < [params count] - 1) {
      [encodedParameterPairs appendString:@"&"];
    }
  }
  
  return encodedParameterPairs;
}

- (NSMutableData *)buildRequestParamsData:(NSDictionary *)params {
  return [NSMutableData dataWithData:[[self buildRequestParamsString:params] dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
}

#pragma mark - AWS Signature
- (NSString *)signedAWSAuthHeaderWithRequest:(ASIHTTPRequest *)request {
  NSString *contentMD5 = [request.requestHeaders objectForKey:@"Content-MD5"] ? [request.requestHeaders objectForKey:@"Content-MD5"] : @"";
  NSString *contentType = [request.requestHeaders objectForKey:@"Content-Type"] ? [request.requestHeaders objectForKey:@"Content-Type"] : @"";
  NSString *date = [request.requestHeaders objectForKey:@"Date"] ? [request.requestHeaders objectForKey:@"Date"] : @"";
  NSString *acl = [request.requestHeaders objectForKey:@"x-amz-acl"] ? [NSString stringWithFormat:@"x-amz-acl:%@", [request.requestHeaders objectForKey:@"x-amz-acl"]] : @"";
  
  NSString *resource = [request.url path];

  NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@\n%@", request.requestMethod, contentMD5, contentType, date, acl, resource];
  
  DLog(@"String to sign: %@", stringToSign);
  
  NSString *signature = [[stringToSign dataUsingEncoding:NSASCIIStringEncoding] signedHMACStringWithKey:S3_SECRET_KEY usingAlgorithm:kCCHmacAlgSHA1];
  DLog(@"Got signature: %@", signature);
  return signature;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kCoreDataDidReset object:nil];
  for (ASIHTTPRequest *request in _pendingRequests) {
    [request clearDelegatesAndCancel];
  }
  [_pendingRequests removeAllObjects];
  RELEASE_SAFELY(_pendingRequests);
  [super dealloc];
}

@end

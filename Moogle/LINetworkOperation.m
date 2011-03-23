//
//  LINetworkOperation.m
//  NetworkStack
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//

#import "LINetworkOperation.h"
#import "NSString+URLEncoding.h"

#define JSON_REQUEST_HEADER @"application/json"

#pragma mark Static Veriables
// The default number of seconds to use for a timeout
static NSTimeInterval _defaultTimeOutSeconds = 30;

// Used to track how many operations are active
static NSUInteger _activeOperationCount = 0;

@interface LINetworkOperation (Private)

+ (void)showNetworkActivityIndicator;
+ (void)hideNetworkActivityIndicator;
+ (void)hideNetworkActivityIndicatorAfterDelay;
+ (void)hideNetworkActivityIndicatorIfNeeded;

- (void)prepareRequest;
- (void)buildRequestHeaders;
- (void)buildRequestParams;
- (void)buildRequestData;

- (void)parseResponse;
- (void)parseUrlResponse;
- (void)parseCookies;

// NSOperation
- (void)start;
- (void)finish;
- (void)cancel;

@end

@implementation LINetworkOperation

// Connection
@synthesize connection = _connection;
@synthesize isExecuting = _isExecuting;
@synthesize isFinished = _isFinished;

// Request
@synthesize request = _request;
@synthesize requestURL = _requestURL;
@synthesize requestMethod = _requestMethod;
@synthesize requestContentType = _requestContentType;
@synthesize requestContentLength = _requestContentLength;
@synthesize requestAccept = _requestAccept;
@synthesize requestHeaders = _requestHeaders;
@synthesize requestParams = _requestParams;
@synthesize requestData = _requestData;

// Response
@synthesize responseHeaders = _responseHeaders;
@synthesize responseData = _responseData;
@synthesize urlResponse = _urlResponse;
@synthesize responseError = _responseError;
@synthesize responseCookies = _responseCookies;
@synthesize responseStatusMessage = _responseStatusMessage;
@synthesize responseStatusCode = _responseStatusCode;
@synthesize responseContentLength = _responseContentLength;
@synthesize responseEncoding = _responseEncoding;

// Config
@synthesize defaultResponseEncoding = _defaultResponseEncoding;
@synthesize timeoutInterval = _timeoutInterval;
@synthesize numberOfTimesToRetryOnTimeout = _numberOfTimesToRetryOnTimeout;
@synthesize shouldCompressRequestBody = _shouldCompressRequestBody;
@synthesize allowCompressedResponse = _allowCompressedResponse;
@synthesize shouldTimeout = _shouldTimeout;

// Delegate
@synthesize delegate = _delegate;

#pragma mark Initialization
+ (void)initialize {
  if (self == [LINetworkOperation class]) {
    // Allocs for class (statics)
    
  }
}

- (id)init {
  self = [super init];
  if (self) {
    // Allocs
    _requestHeaders = [[NSMutableDictionary alloc] init];
    _requestParams = [[NSMutableDictionary alloc] init];
    
    // Set defaults
    self.requestMethod = @"GET";
    self.requestContentType = JSON_REQUEST_HEADER;
    self.requestAccept = JSON_REQUEST_HEADER;
    self.defaultResponseEncoding = NSUTF8StringEncoding;
    self.timeoutInterval = _defaultTimeOutSeconds;
    self.numberOfTimesToRetryOnTimeout = 1; // NOT IMPLEMENTED
    self.shouldCompressRequestBody = NO;
    self.allowCompressedResponse = NO;
    self.shouldTimeout = YES; // NOT IMPLEMENTED
    _operationState = NetworkOperationStateIdle;
    
    _isExecuting = NO;
    _isFinished = NO;
  }
  return self;
}

- (id)initWithURL:(NSURL *)URL {
  self = [self init];
  if (self) {
    self.requestURL = URL;
  }
  return self;
}

#pragma mark Operation Methods
- (void)start {
  // Force all our work to be async off the MAIN THREAD
  if (![NSThread isMainThread]) {
    [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    return;
  }
  
  NSLog(@"#start called on thread: %@, isMainThread: %d", [NSThread currentThread], [NSThread isMainThread] );
  
  // Fire KVO notifications
  [self willChangeValueForKey:@"isExecuting"];
  _isExecuting = YES;
  [self didChangeValueForKey:@"isExecuting"];

  // Actually begin the operation
  _operationState = NetworkOperationStateStart;

  // Inform delegate that operation started
  if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidStart:)]) {
    [self.delegate performSelector:@selector(networkOperationDidStart:) withObject:self];
  }
  
  // Increment the number of active operations
  _activeOperationCount++;
  
  // Show network indicator
  [LINetworkOperation showNetworkActivityIndicator];
  
  // Prepare Request
  [self prepareRequest];
  
  // Prepare Connection
  _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
}

- (void)finish {
  NSLog(@"#finish called on thread: %@, isMainThread: %d", [NSThread currentThread], [NSThread isMainThread] );
  
  // Decrement the number of active operations
  _activeOperationCount--;
  
  // Hide network indicator if needed
  [LINetworkOperation hideNetworkActivityIndicatorIfNeeded];
  
  // Fire KVO notifications
  [self willChangeValueForKey:@"isExecuting"];
  [self willChangeValueForKey:@"isFinished"];
  _isExecuting = NO;
  _isFinished = YES;
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
}

- (void)cancel {
  NSLog(@"#cancel called on thread: %@, isMainThread: %d", [NSThread currentThread], [NSThread isMainThread] );
  // Clear the delegate
  self.delegate = nil;
  
  // Cancel the async connection
  [_connection cancel];
  
  // cancel the operation
  [super cancel];
}

#pragma mark Cancel Operation
- (void)clearDelegatesAndCancel {
  [self performSelectorOnMainThread:@selector(cancel) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark NSURLConnection Delegate
// Connection received HTTP response, ready to begin receiving data
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  // Reset or Initialize responseData
  if (_responseData) {
    [_responseData release], _responseData = nil;
  }
  _responseData = [[NSMutableData alloc] init];
  
  // Store the HTTP response
  _urlResponse = [response retain];
  
  // Parse the response status and headers
  [self parseUrlResponse];
  
  // Parse the response cookies
  [self parseCookies];
}

// Connection is receiving data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [_responseData appendData:data];
}

// Connection finished receiving all data
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  // Update Op State
  if ([self isCancelled]) {
    _operationState = NetworkOperationStateCancelled;
    
    // Inform delegate operation was cancelled
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidCancel:)]) {
      [self.delegate performSelector:@selector(networkOperationDidCancel:) withObject:self];
    }
  } else {
    _operationState = NetworkOperationStateFinished;
    
    // Inform delegate operation succeeded
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidFinish:)]) {
      [self.delegate performSelector:@selector(networkOperationDidFinish:) withObject:self];
    }
  }
  
  // Finish op
  [self performSelectorOnMainThread:@selector(finish) withObject:nil waitUntilDone:NO];
}

// Connection failed
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  // Read the error
  _responseError = [error copy];
  
  // Check for timeout
  NSString *errorDomain = [_responseError domain];
  NSInteger errorCode = [_responseError code];
  
  if ([errorDomain isEqualToString:@"NSURLErrorDomain"]) {
    switch (errorCode) {
      case NSURLErrorTimedOut:
        _operationState = NetworkOperationStateTimeout;
        break;
      default:
        _operationState = NetworkOperationStateFailed;
        break;
    }
  }
  
  NSLog(@"#failed with state: %d", _operationState);
  
  // Update Op State
  _operationState = NetworkOperationStateFailed;
  
  if (_operationState == NetworkOperationStateTimeout) {
    // Inform delegate that operation timed out
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidTimeout:)]) {
      [self.delegate performSelector:@selector(networkOperationDidTimeout:) withObject:self];
    }
  } else {
    // Inform delegate that operation failed with generic error
    if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidFail:)]) {
      [self.delegate performSelector:@selector(networkOperationDidFail:) withObject:self];
    }
  }
  
  // Finish op
  [self performSelectorOnMainThread:@selector(finish) withObject:nil waitUntilDone:NO];
}

#pragma mark -
#pragma mark Request Methods
- (void)prepareRequest {
  // Prepare asynchronous request
  // NSMutableURLRequest timeoutInterval must be at least 240 seconds (apple docs) or else it is ignored -- synchronous only
  self.request = [NSMutableURLRequest requestWithURL:self.requestURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeoutInterval];
  
  // Request method
  [self.request setHTTPMethod:self.requestMethod];
  
  // Build request params
  [self buildRequestParams];
  
  // Optionally build requestData
  [self buildRequestData];
  
  // Build request headers
  [self buildRequestHeaders];
  
  // If this is an OAuth operation, sign the request
  if ([self respondsToSelector:@selector(sign)]) {
    [self performSelector:@selector(sign)];
  }
}

- (void)buildRequestHeaders {
  // Build user-defined request headers
  NSArray *allKeys = [self.requestHeaders allKeys];
  NSArray *allValues = [self.requestHeaders allValues];
  for (int i = 0; i < [self.requestHeaders count]; i++) {
    [self addRequestHeader:[allKeys objectAtIndex:i] value:[allValues objectAtIndex:i]];
  }
	
	// Accept a compressed response
	if ([self allowCompressedResponse]) {
		[self addRequestHeader:@"Accept-Encoding" value:@"gzip"];
	}
	
	// Configure a compressed request body
	if ([self shouldCompressRequestBody]) {
		[self addRequestHeader:@"Content-Encoding" value:@"gzip"];
	}
  
  // Content Type
  if (self.requestContentType) {
    [self addRequestHeader:@"Content-Type" value:self.requestContentType];
  }
  
  // Content Length
  if (self.requestContentLength) {
    [self addRequestHeader:@"Content-Length" value:[NSString stringWithFormat:@"%d", self.requestContentLength]];
  }
  
  // Accept
  if (self.requestAccept) {
    [self addRequestHeader:@"Accept" value:self.requestAccept];
  }
  
  //  NSLog(@"Built Request Headers: %@", [self.request allHTTPHeaderFields]);
}

- (void)buildRequestParams {
  if ([self.requestParams count] == 0) return;
  
  NSMutableString *encodedParameterPairs = [[NSMutableString alloc] initWithCapacity:256];
  
  NSArray *allKeys = [self.requestParams allKeys];
  NSArray *allValues = [self.requestParams allValues];
  
  for (int i = 0; i < [self.requestParams count]; i++) {
    [encodedParameterPairs appendFormat:@"%@=%@", [[allKeys objectAtIndex:i] encodedURLParameterString], [[allValues objectAtIndex:i] encodedURLParameterString]];
    if (i < [self.requestParams count] - 1) {
      [encodedParameterPairs appendString:@"&"];
    }
  }
  
  if ([[self.request HTTPMethod] isEqualToString:@"GET"] || [[self.request HTTPMethod] isEqualToString:@"DELETE"]) {
    // GET / DELETE
    [self.request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [self.request URL], encodedParameterPairs]]];
    self.requestData = nil;
  } else {
    // POST / PUT
    self.requestData = [encodedParameterPairs dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    // Set content field and content type
    self.requestContentType = @"application/x-www-form-urlencoded";
    self.requestContentLength = [self.requestData length];
  }
  
  [encodedParameterPairs release];
  // Uses NSMutableURLRequest+Parameters category to set the HTTPbody
  // [self.request setParameters:self.requestParams];
}

- (void)buildRequestData {
  if (self.requestData) {
    [self.request setHTTPBody:self.requestData];
  }
}

- (void)addRequestHeader:(NSString *)header value:(NSString *)value {
  [self.request addValue:value forHTTPHeaderField:header];
}

- (void)addRequestParam:(NSString *)param value:(NSString *)value {
  [self.requestParams setObject:value forKey:param];
}


#pragma mark Response Methods
- (void)parseUrlResponse {
//  NSLog(@"Begin Parsing URL Response");
  
  if ([self.urlResponse isKindOfClass:[NSHTTPURLResponse class]]) {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)self.urlResponse;
    
    self.responseStatusCode = [httpResponse statusCode];
    self.responseStatusMessage = [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]];
    self.responseHeaders = [httpResponse allHeaderFields];
  }
  
  // Parse response expected content length
  self.responseContentLength = [self.urlResponse expectedContentLength];
  
  // Parse response text encoding
  if ([self.urlResponse textEncodingName]) {
    self.responseEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[self.urlResponse textEncodingName]));
  }
}

- (void)parseCookies {
//  NSLog(@"Begin Parsing Cookies");

  NSArray *newCookies = [NSHTTPCookie cookiesWithResponseHeaderFields:self.responseHeaders forURL:self.requestURL];
  self.responseCookies = newCookies;
}


#pragma mark Class Methods
#pragma mark Default time out
+ (NSTimeInterval)defaultTimeOutSeconds {
	return _defaultTimeOutSeconds;
}

+ (void)setDefaultTimeOutSeconds:(NSTimeInterval)newTimeOutSeconds {
	_defaultTimeOutSeconds = newTimeOutSeconds;
}

#pragma mark Network Activity Indicator
+ (void)showNetworkActivityIndicator {
  if (_activeOperationCount > 0) {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  }
}

+ (void)hideNetworkActivityIndicator {
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

+ (void)hideNetworkActivityIndicatorAfterDelay {
	[self performSelector:@selector(hideNetworkActivityIndicatorIfNeeeded) withObject:nil afterDelay:0.5];
}

+ (void)hideNetworkActivityIndicatorIfNeeded {
  if (_activeOperationCount == 0) {
    [self hideNetworkActivityIndicator];
  }
}

#pragma mark Instance Methods
// Call this method to get the received data as an NSString. Don't use for binary data!
- (NSString *)responseString {
	NSData *data = [self responseData];
	if (data) {
      return [[[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:self.responseEncoding] autorelease];
	} else {
      return nil;
  }
}

- (BOOL)isResponseCompressed {
	NSString *encoding = [self.responseHeaders objectForKey:@"Content-Encoding"];
	return encoding && [encoding rangeOfString:@"gzip"].location != NSNotFound;
}
        
#pragma Utility Methods
- (NSString *)description {
  NSMutableDictionary *descDict = [NSMutableDictionary dictionary];
  // Request
  if ([self.request URL]) [descDict setObject:[self.request URL] forKey:@"Request: URL"];
  if ([self.request HTTPMethod]) [descDict setObject:[self.request HTTPMethod] forKey:@"Request: Method"];
  if ([self.request allHTTPHeaderFields]) [descDict setObject:[self.request allHTTPHeaderFields] forKey:@"Request: Headers"];
  if (self.requestContentType) [descDict setObject:self.requestContentType forKey:@"Request: Content Type"];
  if (self.requestAccept) [descDict setObject:self.requestAccept forKey:@"Request: Accept"];
  if (self.requestParams) [descDict setObject:self.requestParams forKey:@"Request: Parameters"];
  // Response
  if (self.responseStatusCode) [descDict setObject:[NSNumber numberWithInteger:self.responseStatusCode] forKey:@"Response: Status Code"];
  if (self.responseStatusMessage) [descDict setObject:self.responseStatusMessage forKey:@"Response Status Message"];
  if (self.responseHeaders) [descDict setObject:self.responseHeaders forKey:@"Response: Headers"];
  if (self.responseError) [descDict setObject:self.responseError forKey:@"Response: Error"];
  if (self.responseContentLength) [descDict setObject:[NSNumber numberWithLongLong:self.responseContentLength] forKey:@"Response: Content Length"];
  
  // Config
  if (self.timeoutInterval) [descDict setObject:[NSNumber numberWithInteger:self.timeoutInterval] forKey:@"Config: Timeout Interval"];
  [descDict setObject:[NSNumber numberWithBool:self.shouldCompressRequestBody] forKey:@"Config: Should Compress Request Body"];
  [descDict setObject:[NSNumber numberWithBool:self.allowCompressedResponse] forKey:@"Config: Allow Compressed Response"];
  [descDict setObject:[NSNumber numberWithBool:self.shouldTimeout] forKey:@"Config: Should Timeout"];
  
  return [descDict description];
}

- (void)dealloc {
  // NEED TO RELEASE A BUNCH OF SHIT
  // Connection
  if (_connection) [_connection release], _connection = nil;
  
  // Request
  if (_request) [_request release], _request = nil;
  if (_requestURL) [_requestURL release], _requestURL = nil;
  if (_requestMethod) [_requestMethod release], _requestMethod = nil;
  if (_requestContentType) [_requestContentType release], _requestContentType = nil;
  if (_requestAccept) [_requestAccept release], _requestAccept = nil;
  if (_requestHeaders) [_requestHeaders release], _requestHeaders = nil;
  if (_requestParams) [_requestParams release], _requestParams = nil;
  if (_requestData) [_requestData release], _requestData = nil;
  
  // Response
  if (_responseHeaders) [_responseHeaders release], _responseHeaders = nil;
  if (_responseData) [_responseData release], _responseData = nil;
  if (_urlResponse) [_urlResponse release], _urlResponse = nil;
  if (_responseError) [_responseError release], _responseError = nil;
  if (_responseCookies) [_responseCookies release], _responseCookies = nil;
  if (_responseStatusMessage) [_responseStatusMessage release], _responseStatusMessage = nil;
  
  [super dealloc];
}

@end
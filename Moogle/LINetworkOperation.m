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

static NSString *_kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3q2f";

// The default number of seconds to use for a timeout
static NSTimeInterval _defaultTimeOutSeconds = 30;

// Used to track how many operations are active
static NSUInteger _activeOperationCount = 0;

static NSThread *_opThread = nil;

@interface LINetworkOperation (Private)

+ (void)showNetworkActivityIndicator;
+ (void)hideNetworkActivityIndicator;
+ (void)hideNetworkActivityIndicatorAfterDelay;
+ (void)hideNetworkActivityIndicatorIfNeeded;

- (void)prepareRequest;
- (void)buildRequestHeaders;
- (void)buildRequestParams;
- (void)buildRequestParamsFormData;
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
@synthesize isCancelled = _isCancelled;
@synthesize isConcurrent = _isConcurrent;

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
@synthesize encodedParameterPairs = _encodedParameterPairs;

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
@synthesize cachePolicy = _cachePolicy;
@synthesize shouldCompressRequestBody = _shouldCompressRequestBody;
@synthesize allowCompressedResponse = _allowCompressedResponse;
@synthesize shouldTimeout = _shouldTimeout;
@synthesize isFormData = _isFormData;

// Delegate
@synthesize delegate = _delegate;

#pragma mark Initialization
+ (void)initialize {
  if (self == [LINetworkOperation class]) {
    // Allocs for class (statics)
    _opThread = [[NSThread alloc] initWithTarget:[self class] selector:@selector(opThreadMain) object:nil];
    [_opThread start];
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
    self.isFormData = NO;
    _operationState = NetworkOperationStateIdle;
    
    self.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    _isExecuting = NO;
    _isFinished = NO;
    _isCancelled = NO;
    _isConcurrent = YES;
    
    _opLock = [[NSLock alloc] init];
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

#pragma mark -
#pragma mark Thread
+ (void)opThreadMain {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  //  NSLog(@"op thread main started on thread: %@", [NSThread currentThread]);
  [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
  [[NSRunLoop currentRunLoop] run];
  [pool release];
}

#pragma mark Operation Methods
- (void)start {
  // Called on MAIN THREAD
  
  // Force all our work to be async off the MAIN THREAD
  if (![NSThread isMainThread]) {
    [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
    return;
  }
  
  if ([self isCancelled]) {
    return;
  }
  
  // Actually begin the operation
  _operationState = NetworkOperationStateStart;
  
  // Inform delegate that operation started
  if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidStart:)]) {
    [self.delegate performSelector:@selector(networkOperationDidStart:) withObject:self];
  }
  
  // Prepare Request
  [self prepareRequest];
  
  // Prepare Connection
  [self performSelector:@selector(startConnection) onThread:_opThread withObject:nil waitUntilDone:NO];
  
}

- (void)startConnection {
  [_opLock lock];
  // Called on OP THREAD
  
  if ([self isCancelled]) {
    return;
  }
  
  // Fire KVO notifications
  [self willChangeValueForKey:@"isExecuting"];
  _isExecuting = YES;
  [self didChangeValueForKey:@"isExecuting"];
  
  // Increment the number of active operations
  _activeOperationCount++;
  
  // Show network indicator
  [[self class] performSelectorOnMainThread:@selector(showNetworkActivityIndicator) withObject:nil waitUntilDone:NO];
  
  _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self];
  [_opLock unlock];
}

- (void)finish {
  [_opLock lock];
  
  // Called on OP THREAD
  
  if ([self isExecuting]) {
    // Decrement the number of active operations
    _activeOperationCount--;
    
    // Hide network indicator if needed
    [[self class] performSelectorOnMainThread:@selector(hideNetworkActivityIndicatorIfNeeded) withObject:nil waitUntilDone:NO];
  }
  
  // Inform Delegate IF NOT CANCELLED
  if (![self isCancelled]) {
    switch (_operationState) {
      case NetworkOperationStateFinished:
        // Inform delegate operation succeeded
        if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidFinish:)]) {
          [self.delegate performSelectorOnMainThread:@selector(networkOperationDidFinish:) withObject:self waitUntilDone:NO];
        }
        break;
      case NetworkOperationStateFailed:
        // Inform delegate that operation failed with generic error
        if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidFail:)]) {
          [self.delegate performSelectorOnMainThread:@selector(networkOperationDidFail:) withObject:self waitUntilDone:NO];
        }
        break;
      case NetworkOperationStateTimeout:
        // Inform delegate that operation timed out
        if (self.delegate && [self.delegate respondsToSelector:@selector(networkOperationDidTimeout:)]) {
          [self.delegate performSelectorOnMainThread:@selector(networkOperationDidTimeout:) withObject:self waitUntilDone:NO];
        }
        break;
      default:
        break;
    }
  }
  
  [_opLock unlock];
  
  // Fire KVO notifications
  [self willChangeValueForKey:@"isExecuting"];
  [self willChangeValueForKey:@"isFinished"];
  _isExecuting = NO;
  _isFinished = YES;
  [self didChangeValueForKey:@"isExecuting"];
  [self didChangeValueForKey:@"isFinished"];
  
  // END OF OPERATION
}

- (void)cancel {
  // Called on OP THREAD
  
  if ([self isFinished]) {
    return;
  }
  
  // cancel the operation
  // Fire KVO notifications
  [self willChangeValueForKey:@"isCancelled"];
  _isCancelled = YES;
  [self didChangeValueForKey:@"isCancelled"];
  
  // Cancel the async connection
  if (_connection) {
    [_connection cancel];
  }
  
  [self finish];
}

#pragma mark Cancel Operation
- (void)cancelOperation {
  // CALLED on REQUESTOR THREAD
  
  [self performSelector:@selector(cancel) onThread:_opThread withObject:nil waitUntilDone:NO];
}

- (void)clearDelegatesAndCancel {
  // Called on REQUESTOR THREAD
  
  // Don't let the delegate disappear until we can safely cancel
  [_opLock lock];
  self.delegate = nil;
  [_opLock unlock];
  
  [self cancelOperation];
}

#pragma mark -
#pragma mark NSURLConnection Delegate
// Connection received HTTP response, ready to begin receiving data
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
  [_opLock lock];
  
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
  
  [_opLock unlock];
}

// Connection is receiving data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
  [_opLock lock];
  [_responseData appendData:data];
  [_opLock unlock];
}

// Connection finished receiving all data
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  [_opLock lock];
  _operationState = NetworkOperationStateFinished;
  [_opLock unlock];
  
  // Finish op
  [self finish];
}

// Connection failed
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [_opLock lock];
  
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
  
  [_opLock unlock];
  
  // Finish op
  [self finish];
}

#pragma mark -
#pragma mark Request Methods
- (void)prepareRequest {
  // Prepare asynchronous request
  // NSMutableURLRequest timeoutInterval must be at least 240 seconds (apple docs) or else it is ignored -- synchronous only
  self.request = [NSMutableURLRequest requestWithURL:self.requestURL cachePolicy:self.cachePolicy timeoutInterval:self.timeoutInterval];
  
  // Request method
  [self.request setHTTPMethod:self.requestMethod];
  
  if (self.isFormData) {
    // Post form data
    [self buildRequestParamsFormData];
  } else {
    // Build request params
    [self buildRequestParams];
  }
  
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
  // When PARAMS are embedded in the URL, this doesn't work!!!
  if ([self.requestParams count] == 0) return;
  
  if (_encodedParameterPairs) {
    [_encodedParameterPairs release], _encodedParameterPairs = nil;
  }
  _encodedParameterPairs = [[NSMutableString alloc] initWithCapacity:256];
  
  
  NSArray *allKeys = [self.requestParams allKeys];
  NSArray *allValues = [self.requestParams allValues];
  
  for (int i = 0; i < [self.requestParams count]; i++) {
    [_encodedParameterPairs appendFormat:@"%@=%@", [[allKeys objectAtIndex:i] encodedURLParameterString], [[allValues objectAtIndex:i] encodedURLParameterString]];
    if (i < [self.requestParams count] - 1) {
      [_encodedParameterPairs appendString:@"&"];
    }
  }
  
  if ([[self.request HTTPMethod] isEqualToString:@"GET"] || [[self.request HTTPMethod] isEqualToString:@"DELETE"]) {
    // GET / DELETE
    [self.request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", [self.request URL], _encodedParameterPairs]]];
    self.requestData = nil;
  } else {
    // POST / PUT
    self.requestData = [NSMutableData dataWithData:[_encodedParameterPairs dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    
    // Set content field and content type
    self.requestContentType = @"application/x-www-form-urlencoded";
    self.requestContentLength = [self.requestData length];
  }
  
  // Uses NSMutableURLRequest+Parameters category to set the HTTPbody
  // [self.request setParameters:self.requestParams];
}

- (void)buildRequestData {
  if (self.requestData) {
    [self.request setHTTPBody:self.requestData];
  }
}

#pragma mark POST DATA
/**
 * Generate body for POST method
 */
- (void)buildRequestParamsFormData {
  self.requestData = [NSMutableData data];
  
  NSString *endLine = [NSString stringWithFormat:@"\r\n--%@\r\n", _kStringBoundary];
  NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
  
  [self.requestData appendData:[[NSString stringWithFormat:@"--%@\r\n", _kStringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
  
  for (id key in [self.requestParams keyEnumerator]) {
    // If image or data
    if (([[self.requestParams valueForKey:key] isKindOfClass:[UIImage class]]) || ([[self.requestParams valueForKey:key] isKindOfClass:[NSData class]])) {
      [dataDictionary setObject:[self.requestParams valueForKey:key] forKey:key];
      continue;
    }
    
    // If text parameter
    [self.requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.requestData appendData:[[self.requestParams valueForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.requestData appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
  }
  
  if ([dataDictionary count] > 0) {
    for (id key in dataDictionary) {
      NSObject *dataParam = [dataDictionary valueForKey:key];
      if ([dataParam isKindOfClass:[UIImage class]]) {
        NSData* imageData = UIImagePNGRepresentation((UIImage*)dataParam);
        [self.requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"image\"; filename=\"%@.png\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.requestData appendData:[[NSString stringWithString:@"Content-Type: image/png\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.requestData appendData:imageData];
      } else {
        NSAssert([dataParam isKindOfClass:[NSData class]],
                 @"dataParam must be a UIImage or NSData");
        
        [self.requestData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; filename=\"%@\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        
        [self.requestData appendData:[[NSString stringWithString:@"Content-Type: content/unknown\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

        [self.requestData appendData:(NSData *)dataParam];

      }
      [self.requestData appendData:[endLine dataUsingEncoding:NSUTF8StringEncoding]];
    }
  }
  
  // Set content field and content type
  NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", _kStringBoundary];
  self.requestContentType = contentType;
  self.requestContentLength = [self.requestData length];
}

- (void)addRequestHeader:(NSString *)header value:(NSString *)value {
  [self.request addValue:value forHTTPHeaderField:header];
}

- (void)addRequestParam:(NSString *)param value:(id)value {
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
    [[self class] performSelectorOnMainThread:@selector(hideNetworkActivityIndicator) withObject:nil waitUntilDone:NO];
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
  if (_encodedParameterPairs) [_encodedParameterPairs release], _encodedParameterPairs = nil;
  
  // Response
  if (_responseHeaders) [_responseHeaders release], _responseHeaders = nil;
  if (_responseData) [_responseData release], _responseData = nil;
  if (_urlResponse) [_urlResponse release], _urlResponse = nil;
  if (_responseError) [_responseError release], _responseError = nil;
  if (_responseCookies) [_responseCookies release], _responseCookies = nil;
  if (_responseStatusMessage) [_responseStatusMessage release], _responseStatusMessage = nil;
  
  if (_opLock) [_opLock release], _opLock = nil;
  
  [super dealloc];
}

@end
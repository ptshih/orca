//
//  LINetworkOperation.h
//  NetworkStack
//
//  Created by Peter Shih on 1/27/11.
//  Copyright 2011 LinkedIn. All rights reserved.
//
//  Things to test:
//  Test GZIP compression/decompression
//  Test all error codes
//  Test cookies
//  Test all delegate callbacks

#import <Foundation/Foundation.h>
#import "LINetworkOperationDelegate.h"

typedef enum {
  NetworkOperationStateIdle = -1,
  NetworkOperationStateStart = 0,
  NetworkOperationStateFinished = 1,
  NetworkOperationStateFailed = 2,
  NetworkOperationStateTimeout = 3,
  NetworkOperationStateCancelled = 4
} NetworkOperationState;

@interface LINetworkOperation : NSOperation {
  // Connection
  NSURLConnection *_connection;
  BOOL _isExecuting;
  BOOL _isFinished;
  BOOL _isCancelled;
  BOOL _isConcurrent;
  
  // Request
  NSMutableURLRequest *_request;
  NSURL *_requestURL;
  NSString *_requestMethod;
  NSString *_requestContentType;
  unsigned long long _requestContentLength;
  NSString *_requestAccept;
  NSMutableDictionary *_requestHeaders;
  NSMutableDictionary *_requestParams; // A dictionary of parameters
  NSData *_requestData;
  NSMutableString *_encodedParameterPairs;
  
  // Response
  NSDictionary *_responseHeaders;
  NSMutableData *_responseData;
  NSURLResponse *_urlResponse;
  NSError *_responseError;
  NSArray *_responseCookies;
  NSString *_responseStatusMessage;
  NSInteger _responseStatusCode;
  unsigned long long _responseContentLength;
  NSStringEncoding _responseEncoding;
  
  // Config
  NSStringEncoding _defaultResponseEncoding;
  NSTimeInterval _timeoutInterval;
  NSInteger _numberOfTimesToRetryOnTimeout;
  NSURLRequestCachePolicy _cachePolicy; // defaults to ignore local
  BOOL _shouldCompressRequestBody;
  BOOL _allowCompressedResponse;
  BOOL _shouldTimeout; // defaults to YES
  
  // Request State
  NetworkOperationState _operationState;
  
  // Delegate
  id <LINetworkOperationDelegate> _delegate;
  
  NSLock *_opLock;
  
  // Stuff to reuse from NSOperation
  // queuePriority
  // addDependency:(NSOperation *)operation
}

// Connection
@property (retain) NSURLConnection *connection;
@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;
@property (readonly) BOOL isCancelled;
@property (readonly) BOOL isConcurrent;

// Request
@property (retain) NSMutableURLRequest *request;
@property (copy) NSURL *requestURL;
@property (retain) NSString *requestMethod;
@property (retain) NSString *requestContentType;
@property (assign) unsigned long long requestContentLength;
@property (retain) NSString *requestAccept;
@property (retain) NSMutableDictionary *requestHeaders;
@property (retain) NSMutableDictionary *requestParams;
@property (retain) NSData *requestData;
@property (retain) NSMutableString *encodedParameterPairs;

// Response
@property (retain) NSDictionary *responseHeaders;
@property (retain) NSMutableData *responseData;
@property (retain) NSURLResponse *urlResponse;
@property (retain) NSError *responseError;
@property (retain) NSArray *responseCookies;
@property (retain) NSString *responseStatusMessage;
@property (assign) NSInteger responseStatusCode;
@property (assign) unsigned long long responseContentLength;
@property (assign) NSStringEncoding responseEncoding;

// Config
@property (assign) NSStringEncoding defaultResponseEncoding;
@property (assign) NSTimeInterval timeoutInterval;
@property (assign) NSInteger numberOfTimesToRetryOnTimeout;
@property (assign) NSURLRequestCachePolicy cachePolicy;
@property (assign) BOOL shouldCompressRequestBody;
@property (assign) BOOL allowCompressedResponse;
@property (assign) BOOL shouldTimeout;

// Delegate
@property (assign) id delegate;

#pragma mark Init
- (id)initWithURL:(NSURL *)URL;

#pragma mark get information about this request
// Returns the contents of the result as an NSString (not appropriate for binary data - used responseData instead)
- (NSString *)responseString;

#pragma mark Configuring Request
- (void)addRequestHeader:(NSString *)header value:(NSString *)value;
- (void)addRequestParam:(NSString *)param value:(NSString *)value;

#pragma mark Cleanup
- (void)cancelOperation;
- (void)clearDelegatesAndCancel;

@end

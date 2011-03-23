//
//  MoogleImageView.m
//  Moogle
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MoogleImageView.h"
#import "LINetworkQueue.h"
#import "LINetworkOperation.h"

@implementation MoogleImageView

@synthesize urlPath = _urlPath;
@synthesize placeholderImage = _placeholderImage;

// Override Setter
- (void)setUrlPath:(NSString *)urlPath {
  if (urlPath) {
    NSString* urlPathCopy = [urlPath copy];
    [_urlPath release];
    _urlPath = urlPathCopy;
    
    // Image not found in cache, fire a request
    LINetworkOperation *op = [[LINetworkOperation alloc] initWithURL:[NSURL URLWithString:_urlPath]];
    op.delegate = self;
    [op setQueuePriority:NSOperationQueuePriorityVeryLow];
    [[LINetworkQueue sharedQueue] addOperation:op];
    [op release];
  }
}

#pragma mark LINetworkOperationDelegate
- (void)networkOperationDidFinish:(LINetworkOperation *)operation {
  UIImage *image = [UIImage imageWithData:[operation responseData]];
  self.image = image;
}

- (void)networkOperationDidFail:(LINetworkOperation *)operation {
  self.image = self.placeholderImage;
}

- (void)dealloc {
  [_urlPath release], _urlPath = nil;
  [_placeholderImage release], _placeholderImage = nil;
  
  [super dealloc];
}
@end

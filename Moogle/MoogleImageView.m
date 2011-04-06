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
#import "LIImageCache.h"

static UIImage *_placeholderImage = nil;

@implementation MoogleImageView

@synthesize urlPath = _urlPath;
@synthesize delegate = _delegate;

+ (void)initialize {
  _placeholderImage = nil;
}

// Override Setter
//- (void)setUrlPath:(NSString *)urlPath {
//  if (urlPath) {
//    NSString* urlPathCopy = [urlPath copy];
//    [_urlPath release];
//    _urlPath = urlPathCopy;
//    
//    // Image not found in cache, fire a request
//    LINetworkOperation *op = [[LINetworkOperation alloc] initWithURL:[NSURL URLWithString:_urlPath]];
//    op.delegate = self;
//    [op setQueuePriority:NSOperationQueuePriorityVeryLow];
//    [[LINetworkQueue sharedQueue] addOperation:op];
//    [op release];
//  }
//}

- (void)loadImage {
  if (_urlPath) {
    UIImage *image = [[LIImageCache sharedCache] imageForURLPath:_urlPath];
    if (image) {
      self.image = image;
    } else {
      _op = [[LINetworkOperation alloc] initWithURL:[NSURL URLWithString:_urlPath]];
      _op.delegate = self;
      _op.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
      [_op setQueuePriority:NSOperationQueuePriorityVeryLow];
      [[LINetworkQueue sharedQueue] addOperation:_op];
    }
  }
}

- (void)unloadImage {
  self.image = _placeholderImage;
  self.urlPath = nil;
}

- (void)imageDidLoad {
  if (self.delegate && [self.delegate respondsToSelector:@selector(imageDidLoad:)]) {
    [self.delegate imageDidLoad:self.image];
  }
}

#pragma mark LINetworkOperationDelegate
- (void)networkOperationDidFinish:(LINetworkOperation *)operation {
  UIImage *image = [UIImage imageWithData:[operation responseData]];
  if (image) {
    [[LIImageCache sharedCache] cacheImage:image forURLPath:[[operation requestURL] absoluteString]];
    self.image = image;
  }
  [self imageDidLoad];
  
  //  NSLog(@"Image width: %f, height: %f", image.size.width, image.size.height);
}

- (void)networkOperationDidFail:(LINetworkOperation *)operation {
  self.image = _placeholderImage;
}

- (void)dealloc {
  if (_op) [_op clearDelegatesAndCancel];
  RELEASE_SAFELY(_op);
  RELEASE_SAFELY(_urlPath);
  
  [super dealloc];
}
@end

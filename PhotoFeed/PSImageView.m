//
//  PSImageView.m
//  PSNetworkStack
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import "PSImageView.h"
#import "PSImageCache.h"
#import "UIImage+ScalingAndCropping.h"

@implementation PSImageView

@synthesize urlPath = _urlPath;
@synthesize placeholderImage = _placeholderImage;
@synthesize shouldScale = _shouldScale;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    _shouldScale = NO;
    _placeholderImage = nil;
    
    _loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _loadingIndicator.hidesWhenStopped = YES;
    _loadingIndicator.frame = self.bounds;
    _loadingIndicator.contentMode = UIViewContentModeCenter;
    [_loadingIndicator startAnimating];
    [self addSubview:_loadingIndicator];
    self.backgroundColor = [UIColor blackColor];
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  _loadingIndicator.frame = self.bounds;
}

- (void)setImage:(UIImage *)image {
  [super setImage:[UIImage imageWithCGImage:image.CGImage scale:2 orientation:image.imageOrientation]];
}

- (void)loadImage {
  if (_urlPath) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:_urlPath];
    //    UIImage *newImage = nil;
    //    if (_shouldScale && image) {
    //      newImage = [image cropProportionalToSize:self.bounds.size];
    //    } else {
    //      newImage = image;
    //    }
    if (image) {
      self.image = image;
      [self imageDidLoad];
    } else {
      self.image = _placeholderImage;
      [_loadingIndicator startAnimating];
      if (_request) {
        [_request clearDelegatesAndCancel];
        RELEASE_SAFELY(_request);
      }
      
      // Fire the request
      NSString *authURL = [NSString stringWithFormat:@"%@?access_token=%@", _urlPath, [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"]];
      _request = [[ASIHTTPRequest requestWithURL:[NSURL URLWithString:authURL]] retain];
      
      // Request Completion Block
      [_request setCompletionBlock:^{
        [self requestFinished:_request];
      }];
      
      // Request Failed Block
      [_request setFailedBlock:^{
        NSError *error = [_request error];
        
        [self requestFailed:_request withError:error];
      }];
      
      // Start the Request
      [_request startAsynchronous];
    }
  }
}

- (void)loadImageIfCached {
  if (_urlPath) {
    UIImage *image = [[PSImageCache sharedCache] imageForURLPath:_urlPath];
    //    UIImage *newImage = nil;
    //    if (_shouldScale && image) {
    //      newImage = image;
    //    } else {
    //      newImage = image;
    //    }
    if (image) {
      self.image = image;
      [self imageDidLoad];
    }
  }
}

- (void)unloadImage {
  if (_request) [_request clearDelegatesAndCancel];
  RELEASE_SAFELY(_request);
  [_loadingIndicator startAnimating];
  self.image = _placeholderImage;
  self.urlPath = nil;
}

- (void)imageDidLoad {
  [_loadingIndicator stopAnimating];
  if (self.delegate && [self.delegate respondsToSelector:@selector(imageDidLoad:)]) {
    [self.delegate imageDidLoad:self.image];
  }
}

#pragma mark Request Finished
- (void)requestFinished:(ASIHTTPRequest *)request {
  // URL
  NSURL *origURL = [[request originalURL] URLByRemovingQuery];
  UIImage *image = [UIImage imageWithData:[request responseData]];
  UIImage *newImage = nil;
  if (image) {
    DLog(@"image size: %@, url: %@", NSStringFromCGSize([image size]), _urlPath);
    if (_shouldScale) {
      newImage = [image cropProportionalToSize:self.bounds.size];
    } else {
      newImage = image;
    }
    [[PSImageCache sharedCache] cacheImage:UIImageJPEGRepresentation(newImage, 1.0) forURLPath:[origURL absoluteString]];
  } else {
    DLog(@"image failed to load for url: %@", [origURL absoluteString]);
  }
  if (newImage) {
    if ([self.urlPath isEqualToString:[origURL absoluteString]]) {
      self.image = newImage;
      [self imageDidLoad];
    } else {
      DLog(@"urlpath: %@, origURL: %@ does NOT match", _urlPath, [origURL absoluteString]);
    }
  }
  
  //  NSLog(@"Image width: %f, height: %f", image.size.width, image.size.height);
}

#pragma mark Request Failed
- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  DLog(@"request: %@ failed with error: %@", request, error);
  self.image = _placeholderImage;
}

- (void)dealloc {
  if (_request) [_request clearDelegatesAndCancel];
  RELEASE_SAFELY(_request);
  RELEASE_SAFELY(_urlPath);
  RELEASE_SAFELY(_loadingIndicator);
  RELEASE_SAFELY(_placeholderImage);
  
  [super dealloc];
}

@end

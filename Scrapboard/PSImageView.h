//
//  PSImageView.h
//  PSNetworkStack
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageViewDelegate.h"
#import "ASIHTTPRequest.h"
#import "Constants.h"

@interface PSImageView : UIImageView <PSImageViewDelegate> {
  NSString *_urlPath;
  UIActivityIndicatorView *_loadingIndicator;
  UIImage *_placeholderImage;
  
  BOOL _shouldScale;
  
  ASIHTTPRequest *_request;
  id <PSImageViewDelegate> _delegate;
}

@property (nonatomic, copy) NSString *urlPath;
@property (nonatomic, retain) UIImage *placeholderImage;
@property (nonatomic, assign) BOOL shouldScale;
@property (nonatomic, assign) id <PSImageViewDelegate> delegate;

- (void)loadImage;
- (void)unloadImage;
- (void)imageDidLoad;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error;

@end

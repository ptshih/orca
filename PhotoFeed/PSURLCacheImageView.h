//
//  PSURLCacheImageView.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageView.h"
#import "ASIHTTPRequest.h"

@interface PSURLCacheImageView : PSImageView {
  NSString *_urlPath;
  
  ASIHTTPRequest *_request;
}

@property (nonatomic, copy) NSString *urlPath;

- (void)loadImage;
- (void)loadImageIfCached;
- (void)unloadImage;

- (void)requestFinished:(ASIHTTPRequest *)request;
- (void)requestFailed:(ASIHTTPRequest *)request withError:(NSError *)error;

@end
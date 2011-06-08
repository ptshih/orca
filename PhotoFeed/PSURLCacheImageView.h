//
//  PSURLCacheImageView.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSImageView.h"

@interface PSURLCacheImageView : PSImageView {
  NSString *_urlPath;
}

@property (nonatomic, copy) NSString *urlPath;

- (void)loadImageAndDownload:(BOOL)download;
- (void)unloadImage;

- (void)imageCacheDidLoad:(NSNotification *)notification;

@end
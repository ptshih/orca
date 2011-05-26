//
//  PSImageView.h
//  PSNetworkStack
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 Seven Minute Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "PSImageViewDelegate.h"

@interface PSImageView : UIImageView {
  UIActivityIndicatorView *_loadingIndicator;
  UIImage *_placeholderImage;
  
  BOOL _shouldScale;
  id <PSImageViewDelegate> _delegate;
}

@property (nonatomic, retain) UIImage *placeholderImage;
@property (nonatomic, assign) BOOL shouldScale;
@property (nonatomic, assign) id <PSImageViewDelegate> delegate;

@end

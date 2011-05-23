//
//  ZoomViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"

@class PSZoomView;

@interface ZoomViewController : PSViewController {
  PSZoomView *_zoomView;
}

@property (nonatomic, assign) PSZoomView *zoomView;

- (void)zoom;

@end

//
//  PSImageCell.h
//  OhSnap
//
//  Created by Peter Shih on 2/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PSCell.h"

#define IMAGE_WIDTH_PLAIN 40.0
#define IMAGE_HEIGHT_PLAIN 40.0
#define IMAGE_WIDTH_GROUPED 34.0
#define IMAGE_HEIGHT_GROUPED 34.0

@interface PSImageCell : PSCell {
  PSImageView *_psImageView;
  UIImageView *_psFrameView;
}

- (void)loadImage;
- (void)loadImageIfCached;

@end

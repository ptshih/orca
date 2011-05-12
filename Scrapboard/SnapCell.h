//
//  SnapCell.h
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCell.h"
#import "Snap.h"

@interface SnapCell : PSCell {
  PSImageView *_photoView; // optional
  UIView *_captionView;
  UIView *_ribbonView;
  
  UILabel *_captionLabel;
  
  NSString *_test;
}

- (void)loadPhoto;
- (void)loadPhotoIfCached;

@end

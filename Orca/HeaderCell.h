//
//  HeaderCell.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSView.h"

@class PSURLCacheImageView;

@interface HeaderCell : PSView {
  PSURLCacheImageView *_profilePicture;
  UILabel *_userNameLabel;
  UILabel *_timestampLabel;
}

+ (CGFloat)headerHeight;
- (void)fillCellWithObject:(id)object;

@end

//
//  HeaderCell.h
//  Scrapboard
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSView.h"
#import "PSImageView.h"
#import "Snap.h"

@interface HeaderCell : PSView {
  PSImageView *_psImageView;
  UILabel *_userNameLabel;
  UILabel *_timestampLabel;
}

- (void)fillCellWithObject:(id)object;

- (void)loadImage;

@end

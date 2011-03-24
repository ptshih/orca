//
//  FeedCell.h
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleImageCell.h"
#import "Feed.h"

@interface FeedCell : MoogleImageCell {
  UILabel *_nameLabel;
  UILabel *_timestampLabel;
  UILabel *_statusLabel;
  UILabel *_commentLabel; // optional
  MoogleImageView *_photoImageView; // optional
}

- (void)fillCellWithFeed:(Feed *)feed;
+ (CGFloat)variableRowHeightWithFeed:(Feed *)feed;

@end

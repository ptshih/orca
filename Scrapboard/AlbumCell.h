//
//  AlbumCell.h
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSImageCell.h"
#import "Album.h"

@interface AlbumCell : PSImageCell {
  UIView *_bubbleView;
  PSImageView *_photoView;
  
  UILabel *_nameLabel;
  UILabel *_messageLabel;
  UILabel *_timestampLabel;
  
  UIView *_activityView;
  UILabel *_activityLabel;
}

- (void)loadPhoto;

@end

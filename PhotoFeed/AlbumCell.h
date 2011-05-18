//
//  AlbumCell.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCell.h"
#import "Album.h"
//#import "PSImageArrayView.h"

@interface AlbumCell : PSCell {
//  PSImageArrayView *_photoView;
  PSImageView *_photoView;
  UIView *_captionView;
  
  UILabel *_nameLabel;
  UILabel *_participantsLabel;
  UILabel *_timestampLabel;
}

- (void)loadPhoto;
- (void)loadPhotoIfCached;

@end

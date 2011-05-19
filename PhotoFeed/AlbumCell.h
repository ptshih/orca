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

@interface AlbumCell : PSCell {
  UIImageView *_photoView;
  UIView *_captionView;
  
  UILabel *_nameLabel;
  UILabel *_captionLabel;
  UILabel *_fromLabel;
  UILabel *_locationLabel;
}

@end

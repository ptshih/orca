//
//  PhotoCell.h
//  Orca
//
//  Created by Peter Shih on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCell.h"

@interface PhotoCell : MessageCell {
  PSURLCacheImageView *_photoView; // optional
}

- (void)loadPhoto;
- (void)loadPhotoFromNotification:(id)notification;

@end

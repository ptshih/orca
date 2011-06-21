//
//  MessageCell.h
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSImageCell.h"
#import "Message.h"
#import "Message+Serialize.h"

@interface MessageCell : PSImageCell {
  Message *_message;
  UILabel *_nameLabel;
  UILabel *_messageLabel;
  UILabel *_timestampLabel;
  PSURLCacheImageView *_photoView; // optional
}

- (void)loadPhoto;
- (void)loadPhotoFromNotification:(id)notification;

@end

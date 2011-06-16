//
//  PodCell.h
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCell.h"
#import "Pod.h"
#import "Pod+Serialize.h"

@interface PodCell : PSCell {
  Pod *_pod;
  UILabel *_nameLabel;
  UILabel *_messageLabel;
  UILabel *_timestampLabel;
  UILabel *_participantsLabel;
  
  UIImageView *_unreadImageView;
}

@end

//
//  MessageCell.h
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSCell.h"
#import "Message.h"
#import "Message+Serialize.h"

@interface MessageCell : PSCell {
  Message *_message;
  UILabel *_messageLabel;
  UIImageView *_quoteView;
}

@end

//
//  KupoComposeViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModalViewController.h"
#import "KupoComposeDelegate.h"
#import "MoogleTextView.h"

@interface KupoComposeViewController : CardModalViewController <UITextViewDelegate> {
  MoogleTextView *_kupoComment;
  UIButton *_photoUpload;
  UIButton *_sendComment;
  
  id <KupoComposeDelegate> _delegate;
}

@property (nonatomic, retain) MoogleTextView *kupoComment;
@property (nonatomic, assign) id <KupoComposeDelegate> delegate;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

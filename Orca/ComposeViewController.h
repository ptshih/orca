//
//  ComposeViewController.h
//  Orca
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModalViewController.h"
#import "ComposeDelegate.h"
#import "PSTextView.h"
#import "ComposeDataCenter.h"

@interface ComposeViewController : CardViewController <UITextViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
  // Caption Bubble
  UIView *_composeView;
  PSTextView *_message;
  
  // Photo Background
  UIImageView *_mediaPreview;
  
  // Snapped Photo
  UIImage *_snappedImage;
  
  id <ComposeDelegate> _delegate;
}

@property (nonatomic, retain) UIImage *snappedImage;
@property (nonatomic, assign) id <ComposeDelegate> delegate;

- (void)send;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

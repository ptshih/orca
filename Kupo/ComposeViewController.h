//
//  ComposeViewController.h
//  Kupo
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModalViewController.h"
#import "ComposeDelegate.h"
#import "PSTextView.h"

@class ComposeDataCenter;

@interface ComposeViewController : CardModalViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
  UIToolbar *_composeToolbar;
  UIView *_composeView;
  UITextField *_tag;
  PSTextView *_message;
  UIImageView *_backgroundView;
  
  // Uploaded Image/Video
  UIImage *_uploadedImage;
  NSData *_uploadedVideo;
  NSString *_uploadedVideoPath;
  
  NSString *_eventId;
  BOOL _shouldSaveToAlbum;
  
  id <ComposeDelegate> _delegate;
}

@property (nonatomic, assign) id <ComposeDelegate> delegate;
@property (nonatomic, retain) PSTextView *message;
@property (nonatomic, retain) NSString *eventId;

- (void)uploadPicture;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

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
#import "UIImage+ScalingAndCropping.h"
#import "ComposeDataCenter.h"

@interface ComposeViewController : CardModalViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate> {
  UIToolbar *_composeToolbar;
  UIView *_composeView;
  PSTextView *_message;
  UIImageView *_backgroundView;
  
  // Photo
  UIButton *_mediaPreview;
  
  // Uploaded Image/Video
  UIImage *_thumbnailImage;
  UIImage *_uploadedImage;
  NSData *_uploadedVideo;
  NSString *_uploadedVideoPath;
  
  BOOL _shouldSaveToAlbum;
  
  id <ComposeDelegate> _delegate;
}

@property (nonatomic, assign) id <ComposeDelegate> delegate;

- (void)send;
- (void)uploadMedia;
- (void)showMedia;
- (void)showFriends;
- (void)showPlaces;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

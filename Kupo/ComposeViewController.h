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

enum {
  KupoComposeTypeKupo = 0,
  KupoComposeTypeCheckin = 1
};
typedef uint32_t KupoComposeType;

@class ComposeDataCenter;

@interface ComposeViewController : CardModalViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
  KupoComposeType _kupoComposeType;
  
  UIView *_composeView;
  PSTextView *_comment;
  UIImageView *_backgroundView;
  UIButton *_photoUpload;
  UIButton *_locationButton;
  
  UIImage *_uploadedImage;
  NSData *_uploadedVideo;
  NSString *_uploadedVideoPath;
  
  NSString *_placeId;
  BOOL _shouldSaveToAlbum;
  
  id <ComposeDelegate> _delegate;
}

@property (nonatomic, assign) id <ComposeDelegate> delegate;
@property (nonatomic, assign) KupoComposeType kupoComposeType;
@property (nonatomic, retain) PSTextView *comment;
@property (nonatomic, retain) NSString *placeId;

- (void)uploadPicture;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

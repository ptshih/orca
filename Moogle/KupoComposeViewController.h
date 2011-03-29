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

@interface KupoComposeViewController : CardModalViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
  UIView *_composeView;
  MoogleTextView *_kupoComment;
  UIImageView *_backgroundView;
  UIButton *_photoUpload;
  UIButton *_locationButton;
  
  UIImage *_uploadedImage;
  
  id <KupoComposeDelegate> _delegate;
}

@property (nonatomic, retain) MoogleTextView *kupoComment;
@property (nonatomic, assign) id <KupoComposeDelegate> delegate;

- (void)uploadPicture;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

//
//  ComposeViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModalViewController.h"
#import "KupoComposeDelegate.h"
#import "MoogleTextView.h"

enum {
  MoogleComposeTypeKupo = 0,
  MoogleComposeTypeCheckin = 1
};
typedef uint32_t MoogleComposeType;

@class ComposeDataCenter;

@interface ComposeViewController : CardModalViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
  MoogleComposeType _moogleComposeType;
  
  UIView *_composeView;
  MoogleTextView *_comment;
  UIImageView *_backgroundView;
  UIButton *_photoUpload;
  UIButton *_locationButton;
  
  UIImage *_uploadedImage;
  NSData *_uploadedVideo;
  NSString *_uploadedVideoPath;
  
  NSString *_placeId;
  BOOL _shouldSaveToAlbum;
  
  id <KupoComposeDelegate> _delegate;
}

@property (nonatomic, assign) id <KupoComposeDelegate> delegate;
@property (nonatomic, assign) MoogleComposeType moogleComposeType;
@property (nonatomic, retain) MoogleTextView *comment;
@property (nonatomic, retain) NSString *placeId;

- (void)uploadPicture;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

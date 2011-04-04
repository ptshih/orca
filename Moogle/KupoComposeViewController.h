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

enum {
  MoogleComposeTypeKupo = 0,
  MoogleComposeTypeCheckin = 1
};
typedef uint32_t MoogleComposeType;

@class KupoComposeDataCenter;

@interface KupoComposeViewController : CardModalViewController <UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate> {
  MoogleComposeType _moogleComposeType;
  
  UIView *_composeView;
  MoogleTextView *_kupoComment;
  UIImageView *_backgroundView;
  UIButton *_photoUpload;
  UIButton *_locationButton;
  
  UIImage *_uploadedImage;
  NSData *_uploadedVideo;
  NSString *_uploadedVideoPath;
  
  LINetworkOperation *_op;
  
  NSString *_placeId;
  
  KupoComposeDataCenter *_dataCenter;
  id <KupoComposeDelegate> _delegate;
}

@property (nonatomic, assign) MoogleComposeType moogleComposeType;

@property (nonatomic, retain) MoogleTextView *kupoComment;
@property (nonatomic, retain) NSString *placeId;
@property (nonatomic, assign) id <KupoComposeDelegate> delegate;

- (void)uploadPicture;

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL)up;

@end

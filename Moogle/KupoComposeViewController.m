//
//  KupoComposeViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoComposeViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+ScalingAndCropping.h"

// Test
#import "LINetworkQueue.h"
#import "LINetworkOperation.h"

#define SPACING 4.0
#define PORTRAIT_HEIGHT 180.0
#define LANDSCAPE_HEIGHT 74.0

@implementation KupoComposeViewController (CameraDelegateMethods)

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [[picker parentViewController] dismissModalViewControllerAnimated:YES];
  [picker release];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
  UIImage *originalImage, *editedImage, *imageToSave, *resizedImage;
  
  // Handle a still image capture
  if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
    editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (editedImage) {
      imageToSave = editedImage;
    } else {
      imageToSave = originalImage;
    }
    
    resizedImage = [imageToSave cropProportionalToSize:CGSizeMake(320, 320)];
    
    
    
    // Save the new image (original or edited) to the Camera Roll
    //    UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    
    if (_uploadedImage) {
      [_uploadedImage release], _uploadedImage = nil;
    }
    _uploadedImage = [imageToSave retain];
    [_photoUpload setImage:_uploadedImage forState:UIControlStateNormal];
  }
  
  // Handle a movie capture
  if (CFStringCompare((CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
    
    NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
    
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
      UISaveVideoAtPathToSavedPhotosAlbum(moviePath, nil, nil, nil);
    }
  }
  
  [[picker parentViewController] dismissModalViewControllerAnimated:YES];
  [picker release];
}

@end

@implementation KupoComposeViewController

@synthesize kupoComment = _kupoComment;
@synthesize delegate = _delegate;

- (id)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
  
  _navTitleLabel.text = @"Write a comment...";
  
  // Show the dismiss button
  [self showDismissButton];
  
  // Send Button
  UIButton *send = [UIButton buttonWithType:UIButtonTypeCustom];
  send.autoresizingMask = UIViewAutoresizingFlexibleHeight;
  send.frame = CGRectMake(0, 0, 60, 32);
  [send setTitle:@"Send" forState:UIControlStateNormal];
  [send setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
  send.titleLabel.font = [UIFont boldSystemFontOfSize:11.0];
  UIImage *sendImage = [[UIImage imageNamed:@"navigationbar_button_standard.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:10];  
  [send setBackgroundImage:sendImage forState:UIControlStateNormal];  
  [send addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];  
  UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithCustomView:send];
  
  self.navigationItem.rightBarButtonItem = sendButton;
  [sendButton release];
  
  _composeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height - 216)];
  _composeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:_composeView];
  
//  _photoUpload = [[UIButton alloc] initWithFrame:CGRectMake(5, 7, 30, 30)];
//  _photoUpload.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//  [_photoUpload setBackgroundImage:[UIImage imageNamed:@"photo_upload.png"] forState:UIControlStateNormal];
//  [self.view addSubview:_photoUpload];
  
//  _sendComment = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 35, 7, 30, 30)];
//  _sendComment.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//  [_sendComment setBackgroundImage:[UIImage imageNamed:@"photo_upload.png"] forState:UIControlStateNormal];
//  [self.view addSubview:_sendComment];
  
  CGFloat top = 10;
  CGFloat left = 10;
  
  _photoUpload = [[UIButton alloc] initWithFrame:CGRectZero];
  _photoUpload.width = 70;
  _photoUpload.height = 70;
  _photoUpload.top = top;
  _photoUpload.left = left;
  [_photoUpload setBackgroundImage:[UIImage imageNamed:@"photo_add.png"] forState:UIControlStateNormal];
  [_photoUpload addTarget:self action:@selector(uploadPicture) forControlEvents:UIControlEventTouchUpInside];
  [_composeView addSubview:_photoUpload];
  
  _locationButton = [[UIButton alloc] initWithFrame:CGRectZero];
  _locationButton.width = 70;
  _locationButton.height = 30;
  _locationButton.top = _photoUpload.bottom + 10;
  _locationButton.left = left;
  [_locationButton setBackgroundImage:[UIImage imageNamed:@"geo_on.png"] forState:UIControlStateNormal];
  [_composeView addSubview:_locationButton];
  
  left = _photoUpload.right + 10;

  _kupoComment = [[MoogleTextView alloc] initWithFrame:CGRectMake(left, top, 220, 30)];
	_kupoComment.returnKeyType = UIReturnKeyDefault;
	_kupoComment.font = [UIFont boldSystemFontOfSize:14.0];
	_kupoComment.delegate = self;
  [_composeView addSubview:_kupoComment];
  
  _backgroundView = [[UIImageView alloc] initWithFrame:_kupoComment.frame];
  _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _backgroundView.image = [[UIImage imageNamed:@"textview_bg.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
  [_composeView insertSubview:_backgroundView atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
  [_kupoComment becomeFirstResponder];
}

- (void)send {
  NSString *baseURLString = [NSString stringWithFormat:@"%@/%@/moogle/test", MOOGLE_BASE_URL, API_VERSION];
  
  LINetworkOperation *op = [[LINetworkOperation alloc] initWithURL:[NSURL URLWithString:baseURLString]];
  op.delegate = self;
  op.requestMethod = POST;
  
  if ([_kupoComment.text length] > 0) {
    [op addRequestParam:@"comment" value:_kupoComment.text];
  }
  [op addRequestParam:@"timestamp" value:[NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]]];
  if (_uploadedImage) {
    op.isFormData = YES;
    [op addRequestParam:@"image" value:_uploadedImage];
  }
  
  [[LINetworkQueue sharedQueue] addOperation:op];
}

- (void)networkOperationDidFinish:(LINetworkOperation *)operation {
//  [self dismissModalViewControllerAnimated:YES];
}

- (void)networkOperationDidFail:(LINetworkOperation *)operation {
  [self dismissModalViewControllerAnimated:YES];
}

- (void)uploadPicture {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
  
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    [actionSheet addButtonWithTitle:@"Take a Photo"];
  }
  [actionSheet addButtonWithTitle:@"Choose from Library"];
  [actionSheet addButtonWithTitle:@"Cancel"];
  actionSheet.delegate = self;
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
  actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
  [actionSheet showInView:self.view];
  [actionSheet autorelease];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
  if(buttonIndex == actionSheet.cancelButtonIndex) return;
  
  UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.allowsEditing = YES;
  imagePicker.delegate = self;
  
  switch (buttonIndex) {
    case 0:
      if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
      }
      break;
    case 1:
      imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
      break;
    default:
      break;
  }
  
  [self presentModalViewController:imagePicker animated:YES];
}

#pragma mark UITextViewDelegate

#pragma mark UIKeyboard
- (void)keyboardWillShow:(NSNotification *)aNotification {
  [self moveTextViewForKeyboard:aNotification up:YES];
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
  [self moveTextViewForKeyboard:aNotification up:NO]; 
}

- (void)moveTextViewForKeyboard:(NSNotification*)aNotification up:(BOOL) up {
  NSDictionary* userInfo = [aNotification userInfo];
  
  // Get animation info from userInfo
  NSTimeInterval animationDuration;
  UIViewAnimationCurve animationCurve;
  
  CGRect keyboardEndFrame;
  
  [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
  [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
  
  
  [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
  
  
  // Animate up or down
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:animationDuration];
  [UIView setAnimationCurve:animationCurve];
  
  CGRect keyboardFrame = [UIScreen convertRect:keyboardEndFrame toView:self.view];
  _composeView.height = self.view.bounds.size.height - keyboardFrame.size.height;
  _kupoComment.height = up ? 180 : 30;
  _backgroundView.height = _kupoComment.height;
//  _photoUpload.top = _kupoComment.bottom + 10;
//  _locationButton.top = _kupoComment.bottom + 10;

  [UIView commitAnimations];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  
  RELEASE_SAFELY(_composeView);
  RELEASE_SAFELY(_photoUpload);
  RELEASE_SAFELY(_kupoComment);
  RELEASE_SAFELY(_locationButton);
  RELEASE_SAFELY(_uploadedImage);
  RELEASE_SAFELY(_backgroundView);
  [super dealloc];
}

@end

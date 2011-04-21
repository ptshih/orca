//
//  ComposeViewController.m
//  Kupo
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

#define SPACING 4.0
#define PORTRAIT_HEIGHT 180.0
#define LANDSCAPE_HEIGHT 74.0

@implementation ComposeViewController (CameraDelegateMethods)

// For responding to the user tapping Cancel.
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [[picker parentViewController] dismissModalViewControllerAnimated:YES];
  [picker release];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
  UIImage *originalImage;
  
  if (_uploadedImage) {
    [_uploadedImage release], _uploadedImage = nil;
  }
  
  if (_uploadedVideo) {
    [_uploadedVideo release], _uploadedVideo = nil;
  }
  
  if (_uploadedVideoPath) {
    [_uploadedVideoPath release], _uploadedVideoPath = nil;
  }
  
  if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
    _shouldSaveToAlbum = YES;
  } else {
    _shouldSaveToAlbum = NO;
  }
    
  // Handle a still image capture
  if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
    originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    
    // Save the new image (original or edited) to the Camera Roll
    // This is only done when the Send button is tapped
    //    UIImageWriteToSavedPhotosAlbum (originalImage, nil, nil , nil);
    
    _uploadedImage = [[originalImage scaleProportionalToSize:CGSizeMake(640, 640)] retain];
//    _uploadedImage = [originalImage retain];
//    [_photoUpload setBackgroundImage:_uploadedImage forState:UIControlStateNormal];
  }
  
  // Handle a movie capture
  if (CFStringCompare((CFStringRef)mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
    _uploadedVideoPath = [[[info objectForKey:UIImagePickerControllerMediaURL] path] retain];
    _uploadedVideo = [[NSData dataWithContentsOfURL:[info objectForKey:UIImagePickerControllerMediaURL]] retain];
    
    // Take a screenshot of the video for a thumbnail
    CGSize sixzevid=CGSizeMake(picker.view.bounds.size.width,picker.view.bounds.size.height);
    UIGraphicsBeginImageContext(sixzevid);
    [picker.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *videoThumbImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    _uploadedImage = [[videoThumbImage cropProportionalToSize:CGSizeMake(320, 320)] retain];
//    [_photoUpload setBackgroundImage:_uploadedImage forState:UIControlStateNormal];
  }
  
  // Write the photo to the user's album
  if (_uploadedImage && !_uploadedVideo && _shouldSaveToAlbum) {
    UIImageWriteToSavedPhotosAlbum(_uploadedImage, nil, nil, nil);
  } else if (_uploadedVideo && _shouldSaveToAlbum) {
    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(_uploadedVideoPath)) {
      UISaveVideoAtPathToSavedPhotosAlbum(_uploadedVideoPath, nil, nil, nil);
    }
  }
  
  [[picker parentViewController] dismissModalViewControllerAnimated:YES];
  [picker release];
}

@end

@implementation ComposeViewController

@synthesize delegate = _delegate;

- (id)init {
  self = [super init];
  if (self) {
    _shouldSaveToAlbum = NO;
    
    [[ComposeDataCenter defaultCenter] setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [_nullView removeFromSuperview];
  self.view.backgroundColor = [UIColor whiteColor];
  
  // Show the dismiss button
  [self showDismissButton];
  
  // Send Button
  UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send") style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
  self.navigationItem.rightBarButtonItem = sendButton;
  [sendButton release];
  
  _composeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
  _composeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:_composeView];

  // Message Field
  _message = [[PSTextView alloc] initWithFrame:CGRectZero];
  _message.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_message.returnKeyType = UIReturnKeyDefault;
	_message.font = [UIFont boldSystemFontOfSize:14.0];
	_message.delegate = self;
  [_composeView addSubview:_message];
  
  // Toolbar
  _composeToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
  _composeToolbar.frame = CGRectMake(0, self.view.bounds.size.height - 44, 320, 44);
  _composeToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
  _composeToolbar.tintColor = NAV_COLOR_DARK_BLUE;
  
  UIBarButtonItem *photoButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-bar-camera.png"] style:UIBarButtonItemStylePlain target:self action:@selector(uploadPicture)] autorelease];
  
  UIBarButtonItem *peopleButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-bar-at.png"] style:UIBarButtonItemStylePlain target:self action:@selector(uploadPicture)] autorelease];
  
  UIBarButtonItem *placeButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-bar-place.png"] style:UIBarButtonItemStylePlain target:self action:@selector(uploadPicture)] autorelease];
  
  NSArray *barItems = [NSArray arrayWithObjects:photoButton, [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], peopleButton, [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], placeButton, nil];

  [_composeToolbar setItems:barItems];
  
  [_composeView addSubview:_composeToolbar];

}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  // Subclass should implement
}

- (void)send {  
  // Subclass should implement
}

- (void)dataCenterDidFinish:(LINetworkOperation *)operation {
}

- (void)dataCenterDidFail:(LINetworkOperation *)operation {
}

- (void)uploadPicture {
  UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
  
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    [actionSheet addButtonWithTitle:@"Take a Photo or Video"];
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
  imagePicker.allowsEditing = NO;
  imagePicker.delegate = self;
  imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType];
  
//  imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
//  imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
  
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

#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  
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
  
  
  CGRect keyboardFrame = CGRectZero;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 30200
  // code for iOS below 3.2
  [[userInfo objectForKey:UIKeyboardBoundsUserInfoKey] getValue:&keyboardEndFrame];
  keyboardFrame = keyboardEndFrame;
#else
  // code for iOS 3.2 ++
  [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
  keyboardFrame = [UIScreen convertRect:keyboardEndFrame toView:self.view];
#endif  
  
  // Animate up or down
  [UIView beginAnimations:nil context:nil];
  [UIView setAnimationDuration:animationDuration];
  [UIView setAnimationCurve:animationCurve];
  
//  if (up) {
//    self.view.height = self.view.height - keyboardFrame.size.height;
//  } else {
//    self.view.height = self.view.height + keyboardFrame.size.height;
//  }
  
  if (up) {
    _composeView.height = self.view.bounds.size.height - keyboardFrame.size.height;
  } else {
    _composeView.height = self.view.bounds.size.height + keyboardFrame.size.height;
  }
  
  _composeToolbar.top = _composeView.height - _composeToolbar.height;
  
//  _message.height = up ? self.view.bounds.size.height - 44 - keyboardFrame.size.height - 20 : 30;
//  _backgroundView.height = _message.height;
//  _photoUpload.top = _message.bottom + 10;
//  _locationButton.top = _message.bottom + 10;

  [UIView commitAnimations];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  
  [[ComposeDataCenter defaultCenter] setDelegate:nil];

  RELEASE_SAFELY(_composeToolbar);
  RELEASE_SAFELY(_composeView);
  RELEASE_SAFELY(_message);
  RELEASE_SAFELY(_uploadedImage);
  RELEASE_SAFELY(_uploadedVideo);
  RELEASE_SAFELY(_uploadedVideoPath);
  RELEASE_SAFELY(_backgroundView);
  [super dealloc];
}

@end

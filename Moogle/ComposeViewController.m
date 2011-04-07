//
//  ComposeViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "UIImage+ScalingAndCropping.h"
#import "Place.h"
#import "ComposeDataCenter.h"

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
    
    _uploadedImage = [[originalImage scaleProportionalToSize:CGSizeMake(280, 280)] retain];
//    _uploadedImage = [originalImage retain];
    [_photoUpload setImage:_uploadedImage forState:UIControlStateNormal];
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
    [_photoUpload setImage:_uploadedImage forState:UIControlStateNormal];
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

@synthesize moogleComposeType = _moogleComposeType;
@synthesize comment = _comment;
@synthesize placeId = _placeId;
@synthesize delegate = _delegate;

- (id)init {
  self = [super init];
  if (self) {
    _moogleComposeType = MoogleComposeTypeKupo;
    _shouldSaveToAlbum = NO;
    
    [[ComposeDataCenter defaultCenter] setDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
  
  if (_moogleComposeType == MoogleComposeTypeKupo) {
    _navTitleLabel.text = @"Write a Comment...";
    
    // Show the dismiss button
    [self showDismissButton];
  } else {
    _navTitleLabel.text = @"Check In Here...";
  }
  
  // Send Button
  UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send") style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
  self.navigationItem.rightBarButtonItem = sendButton;
  [sendButton release];
  
  _composeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 244)];
  _composeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:_composeView];
  
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

  _comment = [[MoogleTextView alloc] initWithFrame:CGRectMake(left, top, 220, 30)];
  _comment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_comment.returnKeyType = UIReturnKeyDefault;
	_comment.font = [UIFont boldSystemFontOfSize:14.0];
	_comment.delegate = self;
  [_composeView addSubview:_comment];
  
  _backgroundView = [[UIImageView alloc] initWithFrame:_comment.frame];
  _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  _backgroundView.image = [[UIImage imageNamed:@"textview_bg.png"] stretchableImageWithLeftCapWidth:15 topCapHeight:15];
  [_composeView insertSubview:_backgroundView atIndex:0];
}

- (void)viewWillAppear:(BOOL)animated {
  [_comment becomeFirstResponder];
}

- (void)send {
  if (_moogleComposeType == MoogleComposeTypeKupo) {
    [_dataCenter sendKupoComposeWithPlaceId:self.placeId andComment:_comment.text andImage:_uploadedImage andVideo:_uploadedVideo];
  } else {
    [_dataCenter sendCheckinComposeWithPlaceId:self.placeId andComment:_comment.text andImage:_uploadedImage andVideo:_uploadedVideo];
  }
  [self dismissModalViewControllerAnimated:YES];
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
  _comment.height = up ? self.view.bounds.size.height - keyboardFrame.size.height - 20 : 30;
  _backgroundView.height = _comment.height;
//  _photoUpload.top = _comment.bottom + 10;
//  _locationButton.top = _comment.bottom + 10;

  [UIView commitAnimations];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  
  [[ComposeDataCenter defaultCenter] setDelegate:nil];
  
  RELEASE_SAFELY(_placeId);
  RELEASE_SAFELY(_composeView);
  RELEASE_SAFELY(_photoUpload);
  RELEASE_SAFELY(_comment);
  RELEASE_SAFELY(_locationButton);
  RELEASE_SAFELY(_uploadedImage);
  RELEASE_SAFELY(_uploadedVideo);
  RELEASE_SAFELY(_uploadedVideoPath);
  RELEASE_SAFELY(_backgroundView);
  [super dealloc];
}

@end

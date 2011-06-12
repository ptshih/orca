//
//  ComposeViewController.m
//  Orca
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeViewController.h"
#import "ComposeDataCenter.h"
#import "UIImage+ScalingAndCropping.h"

#define SPACING 4.0
#define PORTRAIT_HEIGHT 180.0
#define LANDSCAPE_HEIGHT 74.0

@implementation ComposeViewController

@synthesize snappedImage = _snappedImage;
@synthesize delegate = _delegate;

- (id)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  }
  return self;
}

- (void)loadView {
  [super loadView];
  
  self.navigationController.navigationBarHidden = NO;
  
  [_nullView removeFromSuperview];
  self.view.backgroundColor = [UIColor whiteColor];
  
  // Send Button
  UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send") style:UIBarButtonItemStyleBordered target:self action:@selector(send)];
  self.navigationItem.rightBarButtonItem = sendButton;
  [sendButton release];
  
  
  // Media Preview
  _mediaPreview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
  [self.view addSubview:_mediaPreview];
  
  // Set the snapped image as the preview
  UIImage *scaledImage = [_snappedImage cropProportionalToSize:CGSizeMake(_mediaPreview.width * 2, _mediaPreview.height * 2)];
  [_mediaPreview setImage:[UIImage imageWithCGImage:scaledImage.CGImage scale:2 orientation:scaledImage.imageOrientation]];
  
  // Compose Caption Bubble
  _composeView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 50)];
  _composeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:_composeView];

  // Message Field
  _message = [[PSTextView alloc] initWithFrame:_composeView.bounds];
	_message.returnKeyType = UIReturnKeyDefault;
	_message.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
	_message.delegate = self;
  _message.placeholder = @"Add a caption";
  _message.placeholderColor = [UIColor lightGrayColor];
  [_composeView addSubview:_message];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
//  [[ComposeDataCenter sharedInstance] setDelegate:self];
  
  // Subclass should implement
  [_message becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
//  [[ComposeDataCenter sharedInstance] setDelegate:nil];
}

- (void)send {
  [[ComposeDataCenter sharedInstance] sendPhotoWithAlbumId:@"1" andMessage:_message.text andPhoto:_snappedImage shouldShare:YES];
  
  // Dismiss and let the op finish in the background
  [self dismissModalViewControllerAnimated:YES];
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
  
//  if (up) {
//    _composeView.height = self.view.bounds.size.height - keyboardFrame.size.height;
//  } else {
//    _composeView.height = self.view.bounds.size.height + keyboardFrame.size.height;
//  }
  
//  _message.height = up ? self.view.bounds.size.height - 44 - keyboardFrame.size.height - 20 : 30;
//  _backgroundView.height = _message.height;
//  _photoUpload.top = _message.bottom + 10;
//  _locationButton.top = _message.bottom + 10;

  [UIView commitAnimations];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

  RELEASE_SAFELY(_mediaPreview);
  RELEASE_SAFELY(_composeView);
  RELEASE_SAFELY(_message);
  RELEASE_SAFELY(_snappedImage);
  [super dealloc];
}

@end

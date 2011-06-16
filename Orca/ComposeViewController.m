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

@synthesize podId = _podId;
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
  
  self.view.backgroundColor = [UIColor clearColor];
  
  // Compose Caption Bubble
  _composeView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 300, 44)];
  _composeView.backgroundColor = [UIColor whiteColor];
  _composeView.layer.cornerRadius = 5.0;
  _composeView.layer.masksToBounds = YES;
  _composeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:_composeView];

  // Header View
  _headerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, _composeView.width, 44)];
  _headerToolbar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
  
  UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)] autorelease];
  UIBarButtonItem *sendButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"Send") style:UIBarButtonItemStyleDone target:self action:@selector(send)] autorelease];
  UIBarButtonItem *title = [[[UIBarButtonItem alloc] initWithTitle:@"Message" style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
  
  [_headerToolbar setItems:[NSArray arrayWithObjects:cancelButton, [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], title, [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], sendButton, nil]];
  
  // Message Field
  _message = [[PSTextView alloc] initWithFrame:CGRectMake(0, 44, _composeView.width, _composeView.height - _headerToolbar.height)];
  _message.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_message.returnKeyType = UIReturnKeyDefault;
	_message.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
	_message.delegate = self;
  _message.placeholder = @"Write a message...";
  _message.placeholderColor = [UIColor lightGrayColor];
  
  [_composeView addSubview:_headerToolbar];
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
  // Send it asynchronously and dismiss composer
  NSString *sequence = [NSString md5:[NSString uuidString]];
  [[ComposeDataCenter defaultCenter] sendMessage:_message.text andSequence:sequence forPodId:_podId];
  
  // We should create a local copy of this message
  NSTimeInterval currentTimestamp = [[NSDate date] timeIntervalSince1970];
  NSInteger currentTimestampInteger = floor(currentTimestamp);
  
  NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
  [userInfo setValue:_message.text forKey:@"message"];
  [userInfo setValue:_podId forKey:@"podId"];
  [userInfo setValue:sequence forKey:@"sequence"];
  [userInfo setValue:[NSNumber numberWithInteger:currentTimestampInteger] forKey:@"timestamp"];
  [userInfo setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"facebookId"] forKey:@"fromId"];
  [userInfo setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"facebookName"] forKey:@"fromName"];
  [userInfo setValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"facebookPictureUrl"] forKey:@"fromPictureUrl"];
  
  if (self.delegate && [self.delegate respondsToSelector:@selector(composeDidSendWithUserInfo:)]) {
    [self.delegate performSelector:@selector(composeDidSendWithUserInfo:) withObject:userInfo];
  }
  
  [self cancel];
}

- (void)cancel {
  [_message resignFirstResponder];
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
  NSString *dir = up ? @"up" : @"down";
  [UIView beginAnimations:dir context:nil];
  [UIView setAnimationDuration:animationDuration];
  [UIView setAnimationCurve:animationCurve];
  
//  if (up) {
//    self.view.height = self.view.height - keyboardFrame.size.height;
//  } else {
//    self.view.height = self.view.height + keyboardFrame.size.height;
//  }
  
  if (up) {
    _composeView.height = self.view.bounds.size.height - 20 - keyboardFrame.size.height;
  } else {
//    _composeView.height = self.view.bounds.size.height - 40 + keyboardFrame.size.height;
    _composeView.height = 44;
  }

  [UIView commitAnimations];
  
  if ([dir isEqualToString:@"down"]) {
    [self dismissModalViewControllerAnimated:YES];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  
  RELEASE_SAFELY(_podId);
  RELEASE_SAFELY(_composeView);
  RELEASE_SAFELY(_headerToolbar);
  RELEASE_SAFELY(_message);
  RELEASE_SAFELY(_snappedImage);
  [super dealloc];
}

@end

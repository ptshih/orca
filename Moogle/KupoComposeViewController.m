//
//  KupoComposeViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoComposeViewController.h"

#define SPACING 4.0
#define PORTRAIT_HEIGHT 180.0
#define LANDSCAPE_HEIGHT 74.0


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
  
  _navItem.rightBarButtonItem = sendButton;
  [sendButton release];
  
  _navTitleLabel.text = @"Write a comment...";
  
//  _photoUpload = [[UIButton alloc] initWithFrame:CGRectMake(5, 7, 30, 30)];
//  _photoUpload.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
//  [_photoUpload setBackgroundImage:[UIImage imageNamed:@"photo_upload.png"] forState:UIControlStateNormal];
//  [self.view addSubview:_photoUpload];
  
//  _sendComment = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 35, 7, 30, 30)];
//  _sendComment.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//  [_sendComment setBackgroundImage:[UIImage imageNamed:@"photo_upload.png"] forState:UIControlStateNormal];
//  [self.view addSubview:_sendComment];
                  
  _kupoComment = [[MoogleTextView alloc] initWithFrame:CGRectMake(10, 54, 300, 30)];
  _kupoComment.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_kupoComment.returnKeyType = UIReturnKeyDefault;
	_kupoComment.font = [UIFont boldSystemFontOfSize:14.0];
	_kupoComment.delegate = self;
  
  [self.view addSubview:_kupoComment];
}

- (void)viewWillAppear:(BOOL)animated {
  [_kupoComment becomeFirstResponder];
}

- (void)send {
  
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
  
//  CGRect keyboardFrame = [UIScreen convertRect:keyboardEndFrame toView:self.view];
  if (UIInterfaceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
    _kupoComment.height = PORTRAIT_HEIGHT;
  } else {
    _kupoComment.height = LANDSCAPE_HEIGHT;
  }
  [UIView commitAnimations];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  
  RELEASE_SAFELY(_photoUpload);
  RELEASE_SAFELY(_kupoComment);
  RELEASE_SAFELY(_sendComment);
  [super dealloc];
}

@end

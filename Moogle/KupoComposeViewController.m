//
//  KupoComposeViewController.m
//  Moogle
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoComposeViewController.h"

#define SPACING 4.0

@implementation KupoComposeViewController

@synthesize kupoComment = _kupoComment;

@synthesize parentView = _parentView;
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
  self.view.frame = CGRectMake(0, 0, 320, 44);
  
}
- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
  
  _kupoComment = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(SPACING, SPACING, self.view.width - SPACING * 2, 44 - SPACING * 2)];
  _kupoComment.autoresizingMask = UIViewAutoresizingFlexibleWidth;

  
  _kupoComment.minNumberOfLines = 1;
	_kupoComment.maxNumberOfLines = 4;
	_kupoComment.returnKeyType = UIReturnKeyDefault;
	_kupoComment.font = [UIFont boldSystemFontOfSize:14.0];
	_kupoComment.delegate = self;
	//textView.animateHeightChange = NO; //turns off animation
  
  [self.view addSubview:_kupoComment];
}

#pragma mark UITextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
	float diff = (_kupoComment.frame.size.height - height);
  
  // adjust parent view frame also
  self.parentView.height += diff;
  
  // adjust self view
  self.view.height -= diff;
  
	CGRect r = _kupoComment.frame;
//	r.origin.y += diff;
	_kupoComment.frame = r;
}

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
  
//  CGRect newFrame = self.parentView.frame;
  CGRect keyboardFrame = [self.view convertRect:keyboardEndFrame toView:nil];
  self.parentView.height -= keyboardFrame.size.height * (up? 1 : -1);
//  self.parentView.frame = newFrame;
  
  [UIView commitAnimations];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  
  RELEASE_SAFELY(_kupoComment);
  [super dealloc];
}

@end

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
  _kupoComment = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(SPACING, SPACING, self.view.width - SPACING * 2, self.view.height - SPACING * 2)];
  
  _kupoComment.layer.masksToBounds = YES;
  _kupoComment.layer.cornerRadius = 5.0;
  _kupoComment.layer.borderColor = [[UIColor grayColor] CGColor];
  _kupoComment.layer.borderWidth = 1.0;
  
  _kupoComment.minNumberOfLines = 1;
	_kupoComment.maxNumberOfLines = 4;
	_kupoComment.returnKeyType = UIReturnKeyDefault;
	_kupoComment.font = [UIFont boldSystemFontOfSize:15.0f];
	_kupoComment.delegate = self;
	//textView.animateHeightChange = NO; //turns off animation
  
  [self.view addSubview:_kupoComment];
}

#pragma mark UITextViewDelegate
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
	float diff = (_kupoComment.frame.size.height - height);
  
  // adjust parent view frame also
  self.parentView.height -= diff;
  
	CGRect r = _kupoComment.frame;
	r.origin.y += diff;
	_kupoComment.frame = r;
}

#pragma mark UIKeyboard
- (void)keyboardWillShow:(NSNotification *)keyboardNotification {
  UIViewAnimationCurve curve;
  [[[keyboardNotification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
  
  NSTimeInterval duration;
  [[[keyboardNotification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
  
  CGRect endFrame;
  [[[keyboardNotification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&endFrame];
  
  //schedule animation
  [UIView beginAnimations:@"KeyboardAnimationIn" context:NULL];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:curve];
  
  self.parentView.height = self.parentView.height - endFrame.size.height;
  
  [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)keyboardNotification {
  UIViewAnimationCurve curve;
  [[[keyboardNotification userInfo] valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
  
  NSTimeInterval duration;
  [[[keyboardNotification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&duration];
  
  CGRect beginFrame;
  [[[keyboardNotification userInfo] valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue:&beginFrame];
  
  [UIView beginAnimations:@"KeyboardAnimationOut" context:NULL];
  [UIView setAnimationDuration:duration];
  [UIView setAnimationCurve:curve];
  
  self.parentView.height = self.parentView.height + beginFrame.size.height;
  
  [UIView commitAnimations];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
  
  RELEASE_SAFELY(_kupoComment);
  [super dealloc];
}

@end

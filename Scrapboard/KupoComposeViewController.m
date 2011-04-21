//
//  ScrapboardComposeViewController.m
//  Scrapboard
//
//  Created by Peter Shih on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoComposeViewController.h"


@implementation KupoComposeViewController

@synthesize eventId = _eventId;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _navTitleLabel.text = @"New Message";
  
  _message.frame = CGRectMake(0, 0, 320, 156);
  
  [_message becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)send {
  if (![_message hasText] || [_message.text isEqualToString:_message.placeholder]) {
    if (!_uploadedImage) {
      UIAlertView *emptyAlert = [[[UIAlertView alloc] initWithTitle:@"Whoops!" message:@"You must either upload a photo/video or write a message!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
      [emptyAlert show];
      return;
    }
  }
  
  // Subclass should implement
  [[ComposeDataCenter defaultCenter] sendKupoComposeWithEventId:self.eventId andMessage:_message.text andImage:_uploadedImage andVideo:_uploadedVideo];
  [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
  RELEASE_SAFELY(_eventId);
  [super dealloc];
}

@end

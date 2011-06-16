//
//  ConfigViewController.m
//  Orca
//
//  Created by Peter Shih on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "ConfigDataCenter.h"
#import "Pod.h"

@implementation ConfigViewController

@synthesize pod = _pod;

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)loadView {
  [super loadView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupBackgroundWithImage:[UIImage imageNamed:@"weave-bg.png"]];
  
  UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
  [toolbar setItems:[NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)], nil]];
  [self.view addSubview:toolbar];
  [toolbar release];
}
- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)dealloc {
  [super dealloc];
}

@end

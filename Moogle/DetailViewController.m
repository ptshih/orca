//
//  DetailViewController.m
//  Moogle
//
//  Created by Peter Shih on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "NetworkConstants.h"
#import "Kupo.h"

static UIImage *_photoFrame = nil;

@implementation DetailViewController

@synthesize kupo = _kupo;

+ (void)initialize {
  _photoFrame = [[[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] retain];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
  
  _navTitleLabel.text = self.kupo.authorName;
  
  // Photo Frame
  _photoFrameView = [[UIImageView alloc] initWithImage:_photoFrame];
  _photoFrameView.frame = CGRectMake(10, 10, 300, 300);
  
  // Photo
  _photoView = [[MoogleImageView alloc] initWithFrame:CGRectMake(20, 20, 280, 280)];
  _photoView.urlPath = [NSString stringWithFormat:@"%@/%@/original/image.png", S3_BASE_URL, _kupo.id];
  [_photoView loadImage];
  
  _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  _commentLabel.top = _photoView.bottom + 10;
  _commentLabel.left = _photoView.left;
  _commentLabel.text = self.kupo.comment;
  _commentLabel.font = [UIFont systemFontOfSize:18.0];
  _commentLabel.numberOfLines = 8;
  _commentLabel.lineBreakMode = UILineBreakModeWordWrap;
  _commentLabel.backgroundColor = [UIColor clearColor];
  
  CGFloat textWidth = 0.0;
  textWidth = _photoView.width;
  [_commentLabel sizeToFitFixedWidth:textWidth];
  
  [self.view addSubview:_photoFrameView];
  [self.view addSubview:_photoView];
  [self.view addSubview:_commentLabel];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadCardController];
}

#pragma mark -
#pragma mark CardViewController
- (void)reloadCardController {
  [super reloadCardController];
  
}

- (void)unloadCardController {
  [super unloadCardController];
}

- (void)dealloc {
  RELEASE_SAFELY(_commentLabel);
  RELEASE_SAFELY(_photoFrameView);
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_kupo);
  [super dealloc];
}

@end
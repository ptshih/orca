//
//  DetailViewController.m
//  Kupo
//
//  Created by Peter Shih on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "NetworkConstants.h"
#import "Kupo.h"
#import "UIImage+ScalingAndCropping.h"

#define COMMENT_FONT_SIZE 16.0

static UIImage *_photoFrame = nil;
static UIImage *_quoteImage = nil;

@implementation DetailViewController

@synthesize kupo = _kupo;

+ (void)initialize {
  _photoFrame = [[[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16] retain];
  _quoteImage = [[UIImage imageNamed:@"quote_mark.png"] retain];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = FB_COLOR_VERY_LIGHT_BLUE;
  
  _navTitleLabel.text = self.kupo.comment;
  
  // Photo Frame
  _photoFrameView = [[UIImageView alloc] initWithImage:_photoFrame];
  _photoFrameView.frame = CGRectMake(10, 10, 300, 100);
  
  // Photo
  _photoView = [[PSImageView alloc] initWithFrame:CGRectMake(20, 20, self.view.bounds.size.width - 40, self.view.bounds.size.height - 40)];
  _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
  _photoView.contentMode = UIViewContentModeScaleAspectFit;
  _photoView.layer.cornerRadius = 10.0;
  _photoView.layer.masksToBounds = YES;
  _photoView.delegate = self;
  _photoView.placeholderImage = [[UIImage imageNamed:@"photo_frame.png"] stretchableImageWithLeftCapWidth:16 topCapHeight:16];
  _photoView.urlPath = [NSString stringWithFormat:@"%@/%@/original/%@", S3_PHOTOS_URL, self.kupo.id, self.kupo.photoFileName];
  [_photoView loadImage];
  
  //  _quoteImageView = [[UIImageView alloc] initWithImage:_quoteImage];
  //  _quoteImageView.hidden = YES;
  
//  _commentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//  _commentLabel.text = self.kupo.comment;
//  _commentLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:COMMENT_FONT_SIZE];
//  _commentLabel.numberOfLines = 0;
//  _commentLabel.lineBreakMode = UILineBreakModeWordWrap;
//  _commentLabel.backgroundColor = [UIColor clearColor];
  
//  [self.view addSubview:_photoFrameView];
  [self.view addSubview:_photoView];
//  [self.view addSubview:_quoteImageView];
//  [self.view addSubview:_commentLabel];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self reloadCardController];
}

#pragma mark -
#pragma mark ImageViewDelegate
- (void)imageDidLoad:(UIImage *)image {
//  [UIView beginAnimations:nil context:nil];
//  [UIView setAnimationDuration:0.4];
//  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//  [UIView commitAnimations];
  
//  CGFloat left = _photoView.left;
//  CGFloat top = _photoView.bottom + 10;
//  
//  // Comment Label
//  if ([_commentLabel.text length] > 0) {
//    _quoteImageView.hidden = NO;
//    _quoteImageView.left = left;
//    _quoteImageView.top = top;
//  } else {
//    _quoteImageView.hidden = YES;
//  }
//  
//  CGFloat textWidth = 0.0;
//  textWidth = _photoView.width - _quoteImageView.width - 5;
//  [_commentLabel sizeToFitFixedWidth:textWidth];
//  _commentLabel.left = left + _quoteImageView.width + 5;
//  _commentLabel.top = top;
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
  RELEASE_SAFELY(_quoteImageView);
  RELEASE_SAFELY(_commentLabel);
  RELEASE_SAFELY(_photoFrameView);
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_kupo);
  [super dealloc];
}

@end
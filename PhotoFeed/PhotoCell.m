//
//  PhotoCell.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PhotoCell.h"
#import "PSCoreDataImageCache.h"
#import "UIImage+ScalingAndCropping.h"

#define CAPTION_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]

@implementation PhotoCell

@synthesize photoView = _photoView;
@synthesize captionLabel = _captionLabel;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhoto:) name:kImageCached object:nil];
    
    _photoWidth = 0;
    _photoHeight = 0;
    
    _captionLabel = [[UILabel alloc] init];
    
    // Background Color
    _captionLabel.backgroundColor = [UIColor clearColor];
    
    // Font
    _captionLabel.font = CAPTION_FONT;
    
    // Text Color
    _captionLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    
    // Line Break Mode
    _captionLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    // Number of Lines
    _captionLabel.numberOfLines = 3;
    
    // Shadows
    _captionLabel.shadowColor = [UIColor blackColor];
    _captionLabel.shadowOffset = CGSizeMake(0, 1);
    
    // Caption
    _captionView = [[UIView alloc] init];
    _captionView.backgroundColor = [UIColor blackColor];
    _captionView.layer.opacity = 0.667;
    
    // Photo
    _photoView = [[PSImageView alloc] initWithFrame:CGRectZero];
    //    _photoView.shouldScale = YES;
    //    _photoView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    //    _photoView.layer.borderWidth = 1.0;
    
    // Add to contentView
    [self.contentView addSubview:_photoView];
    [self.contentView addSubview:_captionView];
    
    // Add labels
    [self.contentView addSubview:_captionLabel];
    
    UIPinchGestureRecognizer *zoomGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchZoom:)];
    [self addGestureRecognizer:zoomGesture];
    [zoomGesture release];
  }
  return self;
}

- (void)pinchZoom:(UIPinchGestureRecognizer *)sender {
  DLog(@"detected pinch gesture with state: %d", [sender state]);
  if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateChanged) {
    CGFloat factor = [sender scale];
    DLog(@"scale: %f", [sender scale]);
    if (factor > 1.5) {
      // pinch triggered
    }
  } else if (sender.state == UIGestureRecognizerStateRecognized) {
    if ([sender scale] > 1.0) {
      [self triggerPinch];
    } else {
      // this is a shrink not a zoom
    }
  }
}

- (void)triggerPinch {
  if (self.delegate && [self.delegate respondsToSelector:@selector(pinchZoomTriggeredForCell:)]) {
    [self.delegate performSelector:@selector(pinchZoomTriggeredForCell:) withObject:self];
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _captionLabel.text = nil;
  _photoView.image = nil;
  _photoWidth = 0;
  _photoHeight = 0;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  // Photo
  _photoView.frame = CGRectMake(0, 0, 320, floor(_photoHeight / (_photoWidth / 320)));
  
  CGFloat top = _photoView.bottom;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = self.contentView.width - MARGIN_X * 2;
  CGSize desiredSize = CGSizeZero;
  
  // Caption Label
  if ([_captionLabel.text length] > 0) {    
    // Caption
    desiredSize = [UILabel sizeForText:_captionLabel.text width:textWidth font:_captionLabel.font numberOfLines:3 lineBreakMode:_captionLabel.lineBreakMode];
    _captionLabel.top = top + MARGIN_Y;
    _captionLabel.left = left;
    _captionLabel.width = desiredSize.width;
    _captionLabel.height = desiredSize.height;
    
    // Caption View
    _captionView.top = top;
    _captionView.left = 0;
    _captionView.height = _captionLabel.height + MARGIN_Y * 2;
    _captionView.width = self.contentView.width;
    
    // Move Captions up
    _captionView.top -= _captionView.height;
    _captionLabel.top -= _captionView.height;
  }
  
  //  NSLog(@"layout");
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  Photo *photo = (Photo *)object;
  
  //  CGFloat cellWidth = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation];
  CGFloat desiredHeight = 0;
  
  // Photo
  CGFloat photoWidth = [photo.width floatValue];
  CGFloat photoHeight = [photo.height floatValue];
  
  desiredHeight += floor(photoHeight / (photoWidth / 320));
  
  // Caption
  //  if ([photo.name length] > 0) {
  //    desiredHeight += [UILabel sizeForText:photo.name width:(cellWidth - MARGIN_X * 2) font:CAPTION_FONT numberOfLines:2 lineBreakMode:UILineBreakModeWordWrap].height;
  //    desiredHeight += MARGIN_Y * 2;
  //  }
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Photo *photo = (Photo *)object;
  _photo = photo;
  
  _photoWidth = [photo.width integerValue];
  _photoHeight = [photo.height integerValue];
  
  // Photo
  if (photo.imageData) {
    UIImage *cachedImage = [UIImage imageWithData:photo.imageData];
    _photoView.image = cachedImage;
  } else {
    [[PSCoreDataImageCache sharedCache] cacheImageWithURLPath:photo.source forEntity:photo];
    _photoView.image = nil;
  }
  
  // Caption
  _captionLabel.text = photo.name;
}

- (void)loadPhoto:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  if ([[userInfo objectForKey:@"entity"] isEqual:_photo]) {
    _photoView.image = [UIImage imageWithData:_photo.imageData];
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCached object:nil];
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_captionView);
  
  RELEASE_SAFELY(_captionLabel);
  [super dealloc];
}

@end

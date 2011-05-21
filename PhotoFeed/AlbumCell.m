//
//  AlbumCell.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumCell.h"
#import "PSCoreDataImageCache.h"
#import "UIImage+ScalingAndCropping.h"

#define ALBUM_CELL_HEIGHT 120.0

#define NAME_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0]
#define CAPTION_FONT [UIFont fontWithName:@"Chalkboard SE" size:12.0]
#define SMALL_ITALIC_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0]
#define RIBBON_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0]

static UIImage *_ribbonImage = nil;

@implementation AlbumCell

+ (void)initialize {
  _ribbonImage = [[[UIImage imageNamed:@"ribbon.png"] stretchableImageWithLeftCapWidth:30 topCapHeight:0] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPhoto:) name:kImageCached object:nil];
    
    _isAnimating = NO;
    _photoWidth = 0;
    _photoHeight = 0;
    
    _nameLabel = [[UILabel alloc] init];
    _captionLabel = [[UILabel alloc] init];
    _fromLabel = [[UILabel alloc] init];
    _locationLabel = [[UILabel alloc] init];
    _countLabel = [[UILabel alloc] init];
    
    // Background Color
    _nameLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _fromLabel.backgroundColor = [UIColor clearColor];
    _locationLabel.backgroundColor = [UIColor clearColor];
    _countLabel.backgroundColor = [UIColor clearColor];
    
    // Font
    _nameLabel.font = NAME_FONT;
    _captionLabel.font = CAPTION_FONT;
    _fromLabel.font = SMALL_ITALIC_FONT;
    _locationLabel.font = SMALL_ITALIC_FONT;
    _countLabel.font = RIBBON_FONT;
    
    // Text Color
    _nameLabel.textColor = [UIColor whiteColor];
    _captionLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    _fromLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    _locationLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    _countLabel.textColor = [UIColor whiteColor];
    
    // Text Alignment
    _fromLabel.textAlignment = UITextAlignmentRight;
    _locationLabel.textAlignment = UITextAlignmentRight;
    _countLabel.textAlignment = UITextAlignmentRight;
    
    // Line Break Mode
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _captionLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _fromLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _locationLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _countLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Number of Lines
    _nameLabel.numberOfLines = 1;
    _captionLabel.numberOfLines = 1;
    _fromLabel.numberOfLines = 1;
    _locationLabel.numberOfLines = 1;
    _countLabel.numberOfLines = 1;
    
    // Shadows
    _nameLabel.shadowColor = [UIColor blackColor];
    _nameLabel.shadowOffset = CGSizeMake(0, 1);
    _captionLabel.shadowColor = [UIColor blackColor];
    _captionLabel.shadowOffset = CGSizeMake(0, 1);
    //    _countLabel.shadowColor = [UIColor blackColor];
    //    _countLabel.shadowOffset = CGSizeMake(0, 1);
    
    // Caption
    _captionView = [[UIView alloc] initWithFrame:CGRectZero];
    _captionView.backgroundColor = [UIColor blackColor];
    _captionView.layer.opacity = 0.667;
    
    // Photo
    _photoView = [[PSImageView alloc] initWithFrame:CGRectMake(0, 0, 320, ALBUM_CELL_HEIGHT)];
//    _photoView = [[PSImageView alloc] initWithFrame:CGRectZero];

    // Ribbon
    _ribbonView = [[UIView alloc] initWithFrame:CGRectMake(320 - 68, 10, 68, 24)];
    UIImageView *ribbonImageView = [[[UIImageView alloc] initWithImage:_ribbonImage] autorelease];
    ribbonImageView.frame = _ribbonView.bounds;
    [_ribbonView addSubview:ribbonImageView];
    _countLabel.frame = _ribbonView.bounds;
    [_ribbonView addSubview:_countLabel];
    
    // Add to contentView
    [self.contentView addSubview:_photoView];
    [self.contentView addSubview:_captionView];
    [self.contentView addSubview:_ribbonView];
    
    // Add labels
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_captionLabel];
    [self.contentView addSubview:_fromLabel];
    [self.contentView addSubview:_locationLabel];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _captionLabel.text = nil;
  _fromLabel.text = nil;
  _locationLabel.text = nil;
//  _photoView.image = nil;
  _photoWidth = 0;
  _photoHeight = 0;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  // Photo
  
  // Check to see if there is a caption
  if ([_captionLabel.text length] > 0) {
    _captionView.frame = CGRectMake(0, 86, 320, 34);
  } else {
    _captionView.frame = CGRectMake(0, 100, 320, 20);
  }
  
  CGFloat top = _captionView.top;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = self.contentView.width - MARGIN_X * 2;
  CGSize desiredSize = CGSizeZero;
  
  // From/Author
  desiredSize = [UILabel sizeForText:_fromLabel.text width:textWidth font:_fromLabel.font numberOfLines:1 lineBreakMode:_fromLabel.lineBreakMode];
  _fromLabel.top = top + 2.0;
  _fromLabel.left = self.contentView.width - desiredSize.width - MARGIN_X;
  _fromLabel.width = desiredSize.width;
  _fromLabel.height = desiredSize.height;
  
  // Name
  desiredSize = [UILabel sizeForText:_nameLabel.text width:(textWidth - _fromLabel.width - MARGIN_X) font:_nameLabel.font numberOfLines:1 lineBreakMode:_nameLabel.lineBreakMode];
  _nameLabel.top = top + 1.0;
  _nameLabel.left = left;
  _nameLabel.width = desiredSize.width;
  _nameLabel.height = desiredSize.height;
  
  top = _nameLabel.bottom;
  
  if ([_captionLabel.text length] > 0) {    
    // Caption
    desiredSize = [UILabel sizeForText:_captionLabel.text width:textWidth font:_captionLabel.font numberOfLines:1 lineBreakMode:_captionLabel.lineBreakMode];
    _captionLabel.top = top - 5.0; // -2
    _captionLabel.left = left;
    _captionLabel.width = desiredSize.width;
    _captionLabel.height = desiredSize.height;
  }
}


- (void)animateImage {
  // Don't animate it again
  if ([[_photoView.layer animationKeys] containsObject:@"kenBurnsAnimation"]) {
//    NSLog(@"animations: %@", [_photoView.layer animationKeys]);
    return;
  }
  
//  NSLog(@"photoView: %@", NSStringFromCGRect(_photoView.frame));
//  NSLog(@"layer: %@", NSStringFromCGRect(_photoView.layer.frame));
//  NSLog(@"actual w: %f, h: %f", _photoWidth, _photoHeight);
  
  CGFloat width = _photoView.width;
  CGFloat height = _photoView.height;
  
  
  // Zoom/Scale
  CABasicAnimation *zoomAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
  if (width >= height) {
    zoomAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(floor(width * 1.2), floor(height * 1.2))];
    zoomAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(floor(width), floor(height))];
  } else {
    zoomAnimation.fromValue = [NSValue valueWithCGSize:CGSizeMake(width, height)];
    zoomAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(floor(width * 1.2), floor(height * 1.2))];
  }
  
//  zoomAnimation.fillMode = kCAFillModeForwards;
//  resizeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
//  zoomAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//  zoomAnimation.repeatCount = HUGE_VALF;
//  zoomAnimation.autoreverses = YES;
//  zoomAnimation.duration = 10.0;
  
  // Move/Position
  CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
  CGPoint startPt = CGPointMake(160, floor(height / 2));
  CGPoint endPt = CGPointMake(160, floor(height / 3));
  moveAnimation.fromValue = [NSValue valueWithCGPoint:startPt];
  moveAnimation.toValue = [NSValue valueWithCGPoint:endPt];
  
//  NSLog(@"start: %@, end: %@", NSStringFromCGPoint(startPt), NSStringFromCGPoint(endPt));
  
//  
//  CGPoint startPt = CGPointMake(320 / 2, 0);
//  CGPoint endPt = CGPointMake(320 / 2, 120);
//  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
//  anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
//  anim.fromValue = [NSValue valueWithCGPoint:startPt];
//  anim.toValue = [NSValue valueWithCGPoint:endPt];
//  anim.repeatCount = HUGE_VALF;
//  anim.autoreverses = YES;
//  anim.duration = 8.0;
//  [_photoView.layer addAnimation:anim forKey:@"position"];
  
  // Animation Group
  CAAnimationGroup *group = [CAAnimationGroup animation]; 
  group.fillMode = kCAFillModeForwards;
  group.removedOnCompletion = NO;
  group.duration = 15.0;
  group.delegate = self;
  group.autoreverses = YES;
  group.repeatCount = HUGE_VALF;
  group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
  [group setAnimations:[NSArray arrayWithObjects:zoomAnimation, moveAnimation, nil]];
  [group setValue:_photoView forKey:@"imageViewBeingAnimated"];
  [_photoView.layer addAnimation:group forKey:@"kenBurnsAnimation"];
  
//  NSLog(@"animations: %@", [_photoView.layer animationKeys]);
  // Add animation
//  [_photoView.layer addAnimation:resizeAnimation forKey:@"bounds.size"];
  
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return ALBUM_CELL_HEIGHT;
}

- (void)fillCellWithObject:(id)object {
  Album *album = (Album *)object;
  _album = album;
  
  // Photo
  if (album.imageData) {
    //    UIImage *cachedImage = [[UIImage imageWithData:album.imageData] cropProportionalToSize:CGSizeMake(_photoView.width * 2, _photoView.height * 2)];
    UIImage *cachedImage = [UIImage imageWithData:album.imageData];
    [self setPhotoViewWithImage:cachedImage];
  } else {
    NSString *photoURLPath = [NSString stringWithFormat:@"%@?access_token=%@", album.coverPhoto, [[NSUserDefaults standardUserDefaults] valueForKey:@"facebookAccessToken"]];
    [[PSCoreDataImageCache sharedCache] cacheImageWithURLPath:photoURLPath forEntity:album scaledSize:CGSizeZero];
//    [[PSCoreDataImageCache sharedCache] cacheImageWithURLPath:photoURLPath forEntity:album scaledSize:CGSizeMake(_photoView.width * 2, _photoView.height * 2)];
  }
  
  // Labels
  _nameLabel.text = album.name;
  _captionLabel.text = album.caption;
  _fromLabel.text = [NSString stringWithFormat:@"by %@", album.fromName];
  _locationLabel.text = [NSString stringWithFormat:@"at %@", album.location];
  _countLabel.text = [NSString stringWithFormat:@"%@ photos ", album.count];
}

- (void)loadPhoto:(NSNotification *)notification {
  NSDictionary *userInfo = [notification userInfo];
  if ([[userInfo objectForKey:@"entity"] isEqual:_album]) {
    //    UIImage *cachedImage = [[UIImage imageWithData:_album.imageData] cropProportionalToSize:CGSizeMake(_photoView.width * 2, _photoView.height * 2)];
    UIImage *cachedImage = [UIImage imageWithData:_album.imageData];
    [self setPhotoViewWithImage:cachedImage];
  }
}

- (void)setPhotoViewWithImage:(UIImage *)newImage {
  if ([newImage isEqual:_photoView.image]) return;
  _photoView.image = newImage;
   // this is divided by 2 because we are using retina @2x dimensions
  _photoWidth = newImage.size.width;
  _photoHeight = newImage.size.height;
  _photoView.width = self.contentView.width; // 320
  _photoView.height = floor((self.contentView.width / _photoWidth) * _photoHeight);
  [self animateImage];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:kImageCached object:nil];
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_captionView);
  RELEASE_SAFELY(_ribbonView);
  
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_captionLabel);
  RELEASE_SAFELY(_fromLabel);
  RELEASE_SAFELY(_locationLabel);
  RELEASE_SAFELY(_countLabel);
  [super dealloc];
}

@end

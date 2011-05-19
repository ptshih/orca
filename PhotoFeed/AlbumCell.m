//
//  AlbumCell.m
//  PhotoFeed
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumCell.h"

#define NAME_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]
#define CAPTION_FONT [UIFont fontWithName:@"HelveticaNeue" size:12.0]
#define SMALL_ITALIC_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0]

@implementation AlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _nameLabel = [[UILabel alloc] init];
    _captionLabel = [[UILabel alloc] init];
    _fromLabel = [[UILabel alloc] init];
    _locationLabel = [[UILabel alloc] init];
    
    // Background Color
    _nameLabel.backgroundColor = [UIColor clearColor];
    _captionLabel.backgroundColor = [UIColor clearColor];
    _fromLabel.backgroundColor = [UIColor clearColor];
    _locationLabel.backgroundColor = [UIColor clearColor];
    
    // Font
    _nameLabel.font = NAME_FONT;
    _captionLabel.font = CAPTION_FONT;
    _fromLabel.font = SMALL_ITALIC_FONT;
    _locationLabel.font = SMALL_ITALIC_FONT;
    
    // Text Color
    _nameLabel.textColor = [UIColor whiteColor];
    _captionLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    _fromLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    _locationLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    
    // Text Alignment
    _fromLabel.textAlignment = UITextAlignmentRight;
    _locationLabel.textAlignment = UITextAlignmentRight;
    
    // Line Break Mode
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _captionLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _fromLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _locationLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Number of Lines
    _nameLabel.numberOfLines = 1;
    _captionLabel.numberOfLines = 1;
    _fromLabel.numberOfLines = 1;
    _locationLabel.numberOfLines = 1;
    
    // Shadows
    _nameLabel.shadowColor = [UIColor blackColor];
    _nameLabel.shadowOffset = CGSizeMake(0, 1);
    _captionLabel.shadowColor = [UIColor blackColor];
    _captionLabel.shadowOffset = CGSizeMake(0, 1);
    
    // Caption
    _captionView = [[UIView alloc] init];
    _captionView.backgroundColor = [UIColor blackColor];
    _captionView.layer.opacity = 0.667;
    
    // Photo
    _photoView = [[PSImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    _photoView.shouldScale = YES;
    
    // Add to contentView
    [self.contentView addSubview:_photoView];
    [self.contentView addSubview:_captionView];
    
    // Add labels
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_captionLabel];
    [self.contentView addSubview:_fromLabel];
    [self.contentView addSubview:_locationLabel];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _captionLabel.text = nil;
  _fromLabel.text = nil;
  _locationLabel.text = nil;
  [_photoView unloadImage];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  // Check to see if there is a caption
  if ([_captionLabel.text length] > 0) {
    _captionView.frame = CGRectMake(0, 60, 320, 40);
  } else {
    _captionView.frame = CGRectMake(0, 76, 320, 24);
  }
  
  CGFloat top = _captionView.top;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = self.contentView.width - MARGIN_X * 2;
  
  // Timestamp
  [_fromLabel sizeToFitFixedWidth:textWidth withLineBreakMode:_fromLabel.lineBreakMode withNumberOfLines:0];
  _fromLabel.top = top;
  _fromLabel.left = self.contentView.width - _fromLabel.width - MARGIN_X;
  _fromLabel.height = 24.0;
  
  // Name
  [_nameLabel sizeToFitFixedWidth:(textWidth - _fromLabel.width - MARGIN_X) withLineBreakMode:_nameLabel.lineBreakMode withNumberOfLines:1];
  _nameLabel.top = top;
  _nameLabel.left = left;
  _nameLabel.height = 22.0;
  
  top = _nameLabel.bottom;
  
  if ([_captionLabel.text length] > 0) {    
    // Caption
    [_captionLabel sizeToFitFixedWidth:textWidth withLineBreakMode:_captionLabel.lineBreakMode withNumberOfLines:1];
    _captionLabel.top = top;
    _captionLabel.left = left;
    _captionLabel.height = 16.0;
  }
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return 100.0;
}

- (void)fillCellWithObject:(id)object {
  Album *album = (Album *)object;
  
  // Photo
  _photoView.urlPath = album.coverPhoto;
  
  // Photo(s)
//  NSArray *photoArray = [album.photoUrls componentsSeparatedByString:@","];
//  _photoView.urlPath = [photoArray objectAtIndex:0];
//  _photoView.urlPathArray = [photoArray retain];
  
  // Labels
  _nameLabel.text = album.name;
  _captionLabel.text = album.caption;
  _fromLabel.text = [NSString stringWithFormat:@"by %@", album.fromName];
  _locationLabel.text = [NSString stringWithFormat:@"at %@", album.location];
  
  [self loadPhotoIfCached];
}

- (void)loadPhoto {
  [_photoView loadImage];
}

- (void)loadPhotoIfCached {
  [_photoView loadImageIfCached];
}

- (void)dealloc {
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_captionView);
  
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_captionLabel);
  RELEASE_SAFELY(_fromLabel);
  RELEASE_SAFELY(_locationLabel);
  [super dealloc];
}

@end

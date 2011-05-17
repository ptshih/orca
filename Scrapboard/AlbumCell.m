//
//  AlbumCell.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumCell.h"

#define NAME_FONT [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0]
#define PARTICIPANTS_FONT [UIFont fontWithName:@"HelveticaNeue" size:12.0]
#define TIMESTAMP_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:12.0]

@implementation AlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    _nameLabel = [[UILabel alloc] init];
    _participantsLabel = [[UILabel alloc] init];
    _timestampLabel = [[UILabel alloc] init];
    
    // Background Color
    _nameLabel.backgroundColor = [UIColor clearColor];
    _participantsLabel.backgroundColor = [UIColor clearColor];
    _timestampLabel.backgroundColor = [UIColor clearColor];
    
    // Font
    _nameLabel.font = NAME_FONT;
    _participantsLabel.font = PARTICIPANTS_FONT;
    _timestampLabel.font = TIMESTAMP_FONT;
    
    // Text Color
    _nameLabel.textColor = [UIColor whiteColor];
    _participantsLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    _timestampLabel.textColor = FB_COLOR_VERY_LIGHT_BLUE;
    
    // Text Alignment
    _timestampLabel.textAlignment = UITextAlignmentRight;
    
    // Line Break Mode
    _nameLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _participantsLabel.lineBreakMode = UILineBreakModeTailTruncation;
    _timestampLabel.lineBreakMode = UILineBreakModeTailTruncation;
    
    // Number of Lines
    _nameLabel.numberOfLines = 1;
    _participantsLabel.numberOfLines = 1;
    _timestampLabel.numberOfLines = 1;
    
    // Shadows
    _nameLabel.shadowColor = [UIColor blackColor];
    _nameLabel.shadowOffset = CGSizeMake(0, 1);
    _participantsLabel.shadowColor = [UIColor blackColor];
    _participantsLabel.shadowOffset = CGSizeMake(0, 1);
    
    // Caption
    _captionView = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 320, 40)];
    _captionView.backgroundColor = [UIColor blackColor];
    _captionView.layer.opacity = 0.5;
    
    // Photo
    _photoView = [[PSImageArrayView alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    _photoView.shouldScale = YES;
    
    // Add to contentView
    [self.contentView addSubview:_photoView];
    [self.contentView addSubview:_captionView];
    
    // Add labels
    [self.contentView addSubview:_nameLabel];
    [self.contentView addSubview:_participantsLabel];
    [self.contentView addSubview:_timestampLabel];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _nameLabel.text = nil;
  _participantsLabel.text = nil;
  _timestampLabel.text = nil;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = _captionView.top;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = self.contentView.width - MARGIN_X * 2;
  
  // Timestamp
  [_timestampLabel sizeToFitFixedWidth:textWidth withLineBreakMode:_timestampLabel.lineBreakMode withNumberOfLines:0];
  _timestampLabel.top = top;
  _timestampLabel.left = self.contentView.width - _timestampLabel.width - MARGIN_X;
  _timestampLabel.height = 24.0;
  
  // Name
  [_nameLabel sizeToFitFixedWidth:(textWidth - _timestampLabel.width - MARGIN_X) withLineBreakMode:UILineBreakModeTailTruncation withNumberOfLines:1];
  _nameLabel.top = top;
  _nameLabel.left = left;
  _nameLabel.height = 22.0;
  
  top = _nameLabel.bottom;
  
  // Participants
  [_participantsLabel sizeToFitFixedWidth:textWidth withLineBreakMode:UILineBreakModeTailTruncation withNumberOfLines:1];
  _participantsLabel.top = top;
  _participantsLabel.left = left;
  _participantsLabel.height = 16.0;
  
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return 100.0;
}

- (void)fillCellWithObject:(id)object {
  Album *album = (Album *)object;
  
  // Photo(s)
  NSArray *photoArray = [album.photoUrls componentsSeparatedByString:@","];
//  _photoView.urlPath = [photoArray objectAtIndex:0];
  _photoView.urlPathArray = [photoArray retain];
  
  // Labels
  _nameLabel.text = album.name;
  _participantsLabel.text = album.participants;
  _timestampLabel.text = [album.timestamp humanIntervalSinceNow];
  
  [self loadPhotoIfCached];
}

- (void)loadPhoto {
  [_photoView loadImageArray];
}

- (void)loadPhotoIfCached {
  [_photoView loadImageArray];
}

- (void)dealloc {
  RELEASE_SAFELY(_photoView);
  RELEASE_SAFELY(_captionView);
  
  RELEASE_SAFELY(_nameLabel);
  RELEASE_SAFELY(_participantsLabel);
  RELEASE_SAFELY(_timestampLabel);
  [super dealloc];
}

@end

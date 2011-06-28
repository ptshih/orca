//
//  LinkCell.m
//  Orca
//
//  Created by Peter Shih on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LinkCell.h"

#define THUMBNAIL_SIZE 80.0

@implementation LinkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Thumbnail may or may not exist
    _thumbnailView = [[PSURLCacheImageView alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:_thumbnailView];
    
    // YouTube overlay optional
    _overlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"youtube-overlay.png"]];
    _overlayView.hidden = YES;
    [_thumbnailView addSubview:_overlayView];
    
    // Labels
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _sourceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _summaryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    _titleLabel.backgroundColor = [UIColor clearColor];
    _sourceLabel.backgroundColor = [UIColor clearColor];
    _summaryLabel.backgroundColor = [UIColor clearColor];
    
    _titleLabel.font = TITLE_FONT;
    _sourceLabel.font = SOURCE_FONT;
    _summaryLabel.font = SUBTITLE_FONT;
    
    _titleLabel.textColor = TITLE_COLOR;
    _sourceLabel.textColor = SOURCE_COLOR;
    _summaryLabel.textColor = SUMMARY_COLOR;
    
    _titleLabel.numberOfLines = 1;
    _sourceLabel.numberOfLines = 1;
    _summaryLabel.numberOfLines = 3;
    
    [self.contentView addSubview:_titleLabel];
    [self.contentView addSubview:_sourceLabel];
    [self.contentView addSubview:_summaryLabel];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _titleLabel.text = nil;
  _sourceLabel.text = nil;
  _summaryLabel.text = nil;
  
  _overlayView.hidden = YES;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = _messageLabel.bottom;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = self.contentView.width - MARGIN_X - left;
  CGSize desiredSize = CGSizeZero;
  
  // Rich Link
  top += 5;
  
  // Thumbnail
  _thumbnailView.frame = CGRectMake(left, top, THUMBNAIL_SIZE, THUMBNAIL_SIZE);
  left += _thumbnailView.width + MARGIN_X;
  textWidth -= (_thumbnailView.width + MARGIN_X);
  
  // Title
  desiredSize = [UILabel sizeForText:_titleLabel.text width:textWidth font:_titleLabel.font numberOfLines:_titleLabel.numberOfLines lineBreakMode:_titleLabel.lineBreakMode];
  _titleLabel.width = desiredSize.width;
  _titleLabel.height = desiredSize.height;
  _titleLabel.left = left;
  _titleLabel.top = top;
  
  top = _titleLabel.bottom;
  
  // Source
  desiredSize = [UILabel sizeForText:_sourceLabel.text width:textWidth font:_sourceLabel.font numberOfLines:_sourceLabel.numberOfLines lineBreakMode:_sourceLabel.lineBreakMode];
  _sourceLabel.width = desiredSize.width;
  _sourceLabel.height = desiredSize.height;
  _sourceLabel.left = left;
  _sourceLabel.top = top;
  
  top = _sourceLabel.bottom;
  
  // Summary
  desiredSize = [UILabel sizeForText:_summaryLabel.text width:textWidth font:_summaryLabel.font numberOfLines:_summaryLabel.numberOfLines lineBreakMode:_summaryLabel.lineBreakMode];
  _summaryLabel.width = desiredSize.width;
  _summaryLabel.height = desiredSize.height;
  _summaryLabel.left = left;
  _summaryLabel.top = top;
  
  top = _summaryLabel.bottom;
  
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  Message *message = (Message *)object;
  
  CGSize desiredSize = CGSizeZero;
  CGFloat textWidth = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - MARGIN_X * 2 - 16 - 4 - MARGIN_X; // minus quote
  
  CGFloat desiredHeight = 0;
  
  // Top margin
  desiredHeight += MARGIN_Y;
  
  // Message
  desiredSize = [UILabel sizeForText:[[message meta] objectForKey:@"message"] width:textWidth font:NORMAL_FONT numberOfLines:0 lineBreakMode:UILineBreakModeWordWrap];
  desiredHeight += desiredSize.height;
  
  // Rich Link
  desiredHeight += 5;
  desiredHeight += THUMBNAIL_SIZE;
  desiredHeight += 5;
  
  // Bottom margin
  desiredHeight += MARGIN_Y;
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  [super fillCellWithObject:object];
  
  Message *message = (Message *)object;
  
  // read metadata
  NSDictionary *metadata = [message meta];
  
  // If this is a YouTube share, enable play overlay
  if ([message.messageType isEqualToString:@"youtube"]) {
    _overlayView.hidden = NO;
  }
  
  _thumbnailView.urlPath = [metadata objectForKey:@"link_thumbnail_url"] ? [metadata objectForKey:@"link_thumbnail_url"] : @"";
  [_thumbnailView loadImageAndDownload:YES];
  
  _titleLabel.text = [metadata objectForKey:@"link_title"] ? [metadata objectForKey:@"link_title"] : @"";
  _sourceLabel.text = [metadata objectForKey:@"link_source"] ? [metadata objectForKey:@"link_source"] : @"";
  _summaryLabel.text = [metadata objectForKey:@"link_summary"] ? [metadata objectForKey:@"link_summary"] : @"";
  
//  _thumbnailView.urlPath = @"http://static5.businessinsider.com/image/4d8b73adcadcbb1d67220000-400-/colorxxx.jpg";
//  [_thumbnailView loadImageAndDownload:YES];
//  
//  _titleLabel.text = @"Color pivots again!";
//  _sourceLabel.text = @"techcrunch.com";
//  _summaryLabel.text = @"Color CEO decides to pivot again because he is retarded. He has no idea WTF they are doing, but decided to install a stripper pole in their office.";
}

- (void)dealloc {
  RELEASE_SAFELY(_thumbnailView);
  RELEASE_SAFELY(_titleLabel);
  RELEASE_SAFELY(_sourceLabel);
  RELEASE_SAFELY(_summaryLabel);
  RELEASE_SAFELY(_overlayView);
  [super dealloc];
}

@end

//
//  VideoCell.m
//  Orca
//
//  Created by Peter Shih on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoCell.h"

@implementation VideoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Video
    _videoView = [[UIWebView alloc] initWithFrame:CGRectZero];
    _videoView.layer.cornerRadius = 5.0;
    _videoView.layer.masksToBounds = YES;
    _videoView.layer.borderColor = [SEPARATOR_COLOR CGColor];
    _videoView.layer.borderWidth = 1.0;
    [self.contentView addSubview:_videoView];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = _messageLabel.bottom;
  CGFloat left = _quoteView.right + 4.0 + MARGIN_X;
  
  // Photo
  top += 5;
  _videoView.top = top;
  _videoView.left = left;
  _videoView.height = 120;
  _videoView.width = 270;
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
  
  // Video
  desiredHeight += 5;
  desiredHeight += 120;
  desiredHeight += 5;
  
  // Bottom margin
  desiredHeight += MARGIN_Y;
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  [super fillCellWithObject:object];
  
  Message *message = (Message *)object;
  
  NSString *urlString = @"http://www.youtube.com/watch?v=7Xc5wIpUenQ";
  NSString *embedHTML = @"\
  <html><head>\
  <style type=\"text/css\">\
  body {\
  background-color: transparent;\
  color: white;\
  }\
  </style>\
  </head><body style=\"margin:0\">\
  <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
  width=\"%d\" height=\"%d\"></embed>\
  </body></html>";
  NSString *html = [NSString stringWithFormat:embedHTML, urlString, 270, 120];
  [_videoView loadHTMLString:html baseURL:nil];
}


- (void)dealloc {
  RELEASE_SAFELY(_videoView);
  [super dealloc];
}

@end

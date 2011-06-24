//
//  MessageCell.m
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageCell.h"
#import "PSURLCacheImageView.h"

static UIImage *_quoteImage = nil;

@implementation MessageCell

+ (void)initialize {
  _quoteImage = [[UIImage imageNamed:@"quote-mark.png"] retain];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _messageLabel = [[UILabel alloc] init];
    
    // Background Color
    _messageLabel.backgroundColor = [UIColor clearColor];
    
    // Font
    _messageLabel.font = NORMAL_FONT;
    
    // Text Color
    _messageLabel.textColor = [UIColor darkTextColor];
    
    // Text Alignment
    
    // Line Break Mode
    _messageLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    // Number of Lines
    _messageLabel.numberOfLines = 0;
    
    // Shadows
//    _nameLabel.shadowColor = [UIColor whiteColor];
//    _nameLabel.shadowOffset = CGSizeMake(0, -1);
    
    // Quote
    _quoteView = [[UIImageView alloc] initWithImage:_quoteImage];
    [self.contentView addSubview:_quoteView];
    
    // Add labels
    [self.contentView addSubview:_messageLabel];
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
  _messageLabel.text = nil;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  // Quote
  _quoteView.top = MARGIN_Y;
  _quoteView.left = MARGIN_X;
  
  CGFloat top = MARGIN_Y;
  CGFloat left = _quoteView.right + 4.0 + MARGIN_X;
  CGFloat textWidth = self.contentView.width - MARGIN_X - left;
  CGSize desiredSize = CGSizeZero;
  
  // Message
  desiredSize = [UILabel sizeForText:_messageLabel.text width:textWidth font:_messageLabel.font numberOfLines:_messageLabel.numberOfLines lineBreakMode:_messageLabel.lineBreakMode];
  _messageLabel.width = desiredSize.width;
  _messageLabel.height = desiredSize.height;
  _messageLabel.top = top;
  _messageLabel.left = left;
}

#pragma mark -
#pragma mark Fill and Height
+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  Message *message = (Message *)object;
  
  CGSize desiredSize = CGSizeZero;
  CGFloat textWidth = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - MARGIN_X * 2 - 16 - 4 - MARGIN_X; // minus quote
  
  CGFloat desiredHeight = 0;
  
  // Top margin
  desiredHeight += MARGIN_Y;
  
  // Message
  desiredSize = [UILabel sizeForText:message.message width:textWidth font:NORMAL_FONT numberOfLines:0 lineBreakMode:UILineBreakModeWordWrap];
  desiredHeight += desiredSize.height;
  
  // Bottom margin
  desiredHeight += MARGIN_Y;
  
  return desiredHeight;
}

- (void)fillCellWithObject:(id)object {
  Message *message = (Message *)object;
  _message = message;
  
  // Labels
  _messageLabel.text = message.message;
}

- (void)dealloc {
  RELEASE_SAFELY(_messageLabel);
  RELEASE_SAFELY(_quoteView);
  [super dealloc];
}

@end

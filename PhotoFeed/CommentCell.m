//
//  CommentCell.m
//  PhotoFeed
//
//  Created by Peter Shih on 5/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"
#import "Comment.h"

@implementation CommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)layoutSubviews {
  [super layoutSubviews];
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return 44.0;
}

- (void)fillCellWithObject:(id)object {
}

- (void)dealloc {
  [super dealloc];
}

@end

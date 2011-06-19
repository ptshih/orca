//
//  UserCell.m
//  Orca
//
//  Created by Peter Shih on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserCell.h"


@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.clipsToBounds = YES;
    self.selectionStyle = UITableViewCellSelectionStyleBlue;
    
  }
  return self;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.textLabel.left = _psFrameView.right;
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return 60.0;
}

- (void)fillCellWithObject:(id)object {
  NSDictionary *userDict = (NSDictionary *)object;
  
  // Profile Pic
  _psImageView.urlPath = [userDict objectForKey:@"picture_url"];
  [_psImageView loadImageAndDownload:YES];
  
  self.textLabel.text = [userDict objectForKey:@"full_name"];
}

- (void)dealloc {
  [super dealloc];
}

@end

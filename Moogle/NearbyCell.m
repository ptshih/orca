//
//  NearbyCell.m
//  Moogle
//
//  Created by Peter Shih on 4/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NearbyCell.h"


@implementation NearbyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGFloat top = MARGIN_Y;
  CGFloat left = MARGIN_X;
  CGFloat textWidth = 0.0;
  
  left = _moogleFrameView.right;
  
  if (_desiredHeight < _moogleFrameView.bottom) {
    _desiredHeight = _moogleFrameView.bottom + MARGIN_Y;
  }
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

- (void)fillCellWithObject:(id)object {
  NSDictionary *item = object;
  
  self.textLabel.text = [item valueForKey:@"place_name"];
//  self.detailTextLabel.text = [item valueForKey:@"place_street"];
  
  _moogleImageView.urlPath = [item valueForKey:@"place_picture"];
}

+ (MoogleCellType)cellType {
  return MoogleCellTypePlain;
}

- (void)dealloc {
  [super dealloc];
}

@end

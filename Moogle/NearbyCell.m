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
    self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
  }
  return self;
}

- (void)layoutSubviews {
  [super layoutSubviews];
  self.textLabel.left = _moogleFrameView.right;
}

- (void)prepareForReuse {
  [super prepareForReuse];
}

+ (CGFloat)rowHeightForObject:(id)object {
  return 60.0;
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

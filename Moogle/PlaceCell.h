//
//  PlaceCell.h
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleImageCell.h"
#import "Place.h"

@interface PlaceCell : MoogleImageCell {
  UIImageView *_unreadImageView;
  UILabel *_nameLabel;
  UILabel *_timestampLabel;
  UILabel *_summaryLabel;
  UILabel *_activityLabel;
  UILabel *_lastActivityLabel;
  UILabel *_addressLabel;
}

@end

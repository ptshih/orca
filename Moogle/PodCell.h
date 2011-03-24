//
//  PodCell.h
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleImageCell.h"
#import "Pod.h"

@interface PodCell : MoogleImageCell {
  UILabel *_nameLabel;
  UILabel *_timestampLabel;
  UILabel *_summaryLabel;
  UILabel *_activityLabel;
}

- (void)fillCellWithPod:(Pod *)pod;
+ (CGFloat)variableRowHeightWithPod:(Pod *)pod;

@end

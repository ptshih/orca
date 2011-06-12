//
//  HeaderCell.h
//  Orca
//
//  Created by Peter Shih on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSView.h"

@interface HeaderCell : PSView {
  UILabel *_userNameLabel;
  UILabel *_timestampLabel;
}

- (void)fillCellWithObject:(id)object;

@end

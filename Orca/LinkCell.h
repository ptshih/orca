//
//  LinkCell.h
//  Orca
//
//  Created by Peter Shih on 6/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCell.h"

@interface LinkCell : MessageCell {
  PSURLCacheImageView *_thumbnailView;
  UILabel *_titleLabel;
  UILabel *_sourceLabel;
  UILabel *_summaryLabel;
  
  UIImageView *_overlayView;
}

@end

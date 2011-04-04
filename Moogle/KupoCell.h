//
//  KupoCell.h
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleImageCell.h"
#import "Kupo.h"

@interface KupoCell : MoogleImageCell {
  UILabel *_nameLabel;
  UILabel *_timestampLabel;
  UILabel *_statusLabel;
  UILabel *_commentLabel; // optional
  MoogleImageView *_photoImageView; // optional
  BOOL _hasPhoto;
  UIImageView *_quoteImageView;
}

- (void)loadPhoto;
@end

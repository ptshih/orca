//
//  ScrapboardCell.h
//  Scrapboard
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSImageCell.h"
#import "Kupo.h"

@interface KupoCell : PSImageCell {
  UILabel *_nameLabel;
  UILabel *_messageLabel;
  UILabel *_timestampLabel;
  
  Kupo *_kupo;
  UIImageView *_quoteImageView;
  UIImageView *_photoFrameView;
  PSImageView *_photoImageView; // optional
  BOOL _hasPhoto;
}

- (void)loadPhoto;

@end

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
  Kupo *_kupo;
  MoogleImageView *_photoImageView; // optional
  BOOL _hasPhoto;
}

- (void)loadPhoto;
@end

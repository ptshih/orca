//
//  DetailViewController.h
//  Moogle
//
//  Created by Peter Shih on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"
#import "MoogleImageView.h"
#import "MoogleImageViewDelegate.h"

@class Kupo;

@interface DetailViewController : CardViewController <MoogleImageViewDelegate> {
  Kupo *_kupo;
  
  MoogleImageView *_photoView;
  UIImageView *_photoFrameView;
  UILabel *_commentLabel;
  UIImageView *_quoteImageView;
}

@property (nonatomic, retain) Kupo *kupo;

@end

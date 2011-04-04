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

@class Kupo;

@interface DetailViewController : CardViewController {
  Kupo *_kupo;
  
  MoogleImageView *_photoView;
  UIImageView *_photoFrameView;
  UILabel *_commentLabel;
}

@property (nonatomic, retain) Kupo *kupo;

@end

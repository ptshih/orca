//
//  DetailViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"
#import "PSImageView.h"
#import "PSImageViewDelegate.h"

@class Kupo;

@interface DetailViewController : CardViewController <PSImageViewDelegate> {
  Kupo *_kupo;
  
  PSImageView *_photoView;
  UIImageView *_photoFrameView;
  UILabel *_commentLabel;
  UIImageView *_quoteImageView;
}

@property (nonatomic, retain) Kupo *kupo;

@end

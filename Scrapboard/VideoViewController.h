//
//  VideoViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MPMoviePlayerController.h>
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import "CardViewController.h"

@class Kupo;

@interface VideoViewController : CardViewController {
  Kupo *_kupo;
  MPMoviePlayerController *_player;
}

@property (nonatomic, retain) Kupo *kupo;
@property (nonatomic, retain) MPMoviePlayerController *player;

@end

//
//  VideoViewController.m
//  Moogle
//
//  Created by Peter Shih on 4/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "VideoViewController.h"
#import "NetworkConstants.h"
#import "Kupo.h"

@implementation VideoViewController

@synthesize kupo = _kupo;
@synthesize player = _player;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  _navTitleLabel.text = self.kupo.comment;
  
  NSURL *videoUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/original/video.mp4", S3_VIDEOS_URL, self.kupo.id]];
  
  _player = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
  _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _player.view.frame = self.view.bounds;
  _player.controlStyle = MPMovieControlStyleDefault;
  _player.shouldAutoplay = YES;
  
  [self.view addSubview:_player.view];

  
  // Setup player notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:MPMoviePlayerLoadStateDidChangeNotification object:_player];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:_player];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didExitFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:_player];
}

- (void)loadStateDidChange:(NSNotification*)notification {
  MPMoviePlayerController *moviePlayer = [notification object];
  if ([_player respondsToSelector:@selector(setFullscreen:animated:)]) {
    [_player setFullscreen:YES animated:YES];
  }
  if (moviePlayer.loadState == (MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK)) {
  }
}

- (void)playbackDidFinish:(NSNotification*)notification {
  MPMoviePlayerController *moviePlayer = [notification object];
}

- (void)didExitFullscreen:(NSNotification*)notification {
//  [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}

- (void)dealloc {
  RELEASE_SAFELY(_player);
  [super dealloc];
}
@end

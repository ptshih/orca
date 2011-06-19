//
//  CardViewController.h
//  Orca
//
//  Created by Peter Shih on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"
#import "CardStateMachine.h"
#import "UINavigationBar+Custom.h"
//#import "UISearchBar+Custom.h"
#import "PSDataCenterDelegate.h"
#import "HeaderTabView.h"
#import "HeaderTabViewDelegate.h"

enum {
  PSBarButtonTypeNormal = 0,
  PSBarButtonTypeBlue = 1,
  PSBarButtonTypeRed = 2
};
typedef uint32_t PSBarButtonType;

@class PSNullView;

@interface CardViewController : PSViewController <CardStateMachine, PSDataCenterDelegate, HeaderTabViewDelegate> {
  UIScrollView *_activeScrollView; // subclasses should set this if they have a scrollView
  UILabel *_navTitleLabel;
  HeaderTabView *_headerTabView;
  PSNullView *_nullView;
}

- (void)clearCachedData;
- (void)unloadCardController;
- (void)reloadCardController;
- (void)resetCardController;
- (void)dataSourceDidLoad;

- (void)setupNullView;
- (void)setupHeaderTabViewWithFrame:(CGRect)frame;
- (void)setupBackgroundWithImage:(UIImage *)image;

// Nav buttons
- (void)addBackButton;
- (void)addButtonWithTitle:(NSString *)title andSelector:(SEL)selector isLeft:(BOOL)isLeft type:(PSBarButtonType)type;
- (void)addButtonWithImage:(UIImage *)image andSelector:(SEL)selector isLeft:(BOOL)isLeft type:(PSBarButtonType)type;

@end

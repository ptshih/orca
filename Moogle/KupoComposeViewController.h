//
//  KupoComposeViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleViewController.h"
#import "KupoComposeDelegate.h"
#import "HPGrowingTextView.h"

@interface KupoComposeViewController : MoogleViewController <UITextViewDelegate, HPGrowingTextViewDelegate> {
  HPGrowingTextView *_kupoComment;
  
  UIView *_parentView;
  id <KupoComposeDelegate> _delegate;
}

@property (nonatomic, retain) HPGrowingTextView *kupoComment;

@property (nonatomic, assign) UIView *parentView;
@property (nonatomic, assign) id <KupoComposeDelegate> delegate;

@end

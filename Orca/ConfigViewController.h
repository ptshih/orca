//
//  ConfigViewController.h
//  Orca
//
//  Created by Peter Shih on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"

@class Pod;

@interface ConfigViewController : CardViewController {
  Pod *_pod;
}

@property (nonatomic, assign) Pod *pod;

- (void)dismiss;

@end

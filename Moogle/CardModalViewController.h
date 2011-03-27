//
//  CardModalViewController.h
//  Moogle
//
//  Created by Peter Shih on 2/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardViewController.h"

@interface CardModalViewController : CardViewController {
  UINavigationBar *_navigationBar;
  UINavigationItem *_navItem;
  NSString *_dismissButtonTitle;
}

- (void)dismiss;

@end

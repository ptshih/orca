//
//  MeViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModalTableViewController.h"
#import "MoogleImageView.h"

@class MeDataCenter;

@interface MeViewController : CardModalTableViewController {
  
  MeDataCenter *_meDataCenter;
}

@end

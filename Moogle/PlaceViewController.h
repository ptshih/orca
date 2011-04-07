//
//  PlaceViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"
#import "MeDelegate.h"

@interface PlaceViewController : CardCoreDataTableViewController <MeDelegate, UIAlertViewDelegate> {
  NSInteger _limit;
  
  BOOL _shouldReloadOnAppear;
}

@end

//
//  PlaceViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

@class PlaceDataCenter;

@interface PlaceViewController : CardCoreDataTableViewController {
  PlaceDataCenter *_placeDataCenter;
  NSInteger _limit;
}

@end

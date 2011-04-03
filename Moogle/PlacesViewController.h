//
//  PlacesViewController.h
//  Moogle
//
//  Created by Peter Shih on 2/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardModalTableViewController.h"

@class PlacesDataCenter;

@interface PlacesViewController : CardModalTableViewController {
  PlacesDataCenter *_placesDataCenter;
}

@end

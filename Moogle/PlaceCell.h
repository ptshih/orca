//
//  PlaceCell.h
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleImageCell.h"
#import "Place.h"

@interface PlaceCell : MoogleImageCell {
  Place *_place;
  NSMutableArray *_friendPictureArray;
  NSMutableArray *_friendIds;
}

- (void)loadFriendPictures;

@end

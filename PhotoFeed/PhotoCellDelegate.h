//
//  PhotoCellDelegate.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PhotoCell;

@protocol PhotoCellDelegate <NSObject>

- (void)pinchZoomTriggeredForCell:(PhotoCell *)cell;

@end
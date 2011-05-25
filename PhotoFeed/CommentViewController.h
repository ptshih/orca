//
//  CommentViewController.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CardCoreDataTableViewController.h"

@class CommentDataCenter;
@class Photo;

@interface CommentViewController : CardCoreDataTableViewController {
  CommentDataCenter *_commentDataCenter;
  Photo *_photo;
}

@property (nonatomic, assign) Photo *photo;

- (void)newComment;

@end

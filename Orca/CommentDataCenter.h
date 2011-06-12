//
//  CommentDataCenter.h
//  Orca
//
//  Created by Peter Shih on 5/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@class Photo;

@interface CommentDataCenter : PSDataCenter {
  
}

- (NSFetchRequest *)fetchCommentsForPhoto:(Photo *)photo;

@end

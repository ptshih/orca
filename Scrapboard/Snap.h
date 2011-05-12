//
//  Snap.h
//  Scrapboard
//
//  Created by Peter Shih on 5/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment, Like;

@interface Snap : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * mediaType;
@property (nonatomic, retain) NSString * userPictureUrl;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSDecimalNumber * lat;
@property (nonatomic, retain) NSNumber * isLiked;
@property (nonatomic, retain) NSString * albumId;
@property (nonatomic, retain) NSDecimalNumber * lng;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * videoUrl;
@property (nonatomic, retain) NSSet* comments;
@property (nonatomic, retain) NSSet* likes;

@end

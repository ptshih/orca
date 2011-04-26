//
//  Snap.h
//  Scrapboard
//
//  Created by Peter Shih on 4/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Comment;

@interface Snap : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * videoFileName;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * userPictureUrl;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSDecimalNumber * lat;
@property (nonatomic, retain) NSNumber * isLiked;
@property (nonatomic, retain) NSString * albumId;
@property (nonatomic, retain) NSDecimalNumber * lng;
@property (nonatomic, retain) NSString * photoFileName;
@property (nonatomic, retain) NSString * likes;
@property (nonatomic, retain) NSSet* comments;

@end

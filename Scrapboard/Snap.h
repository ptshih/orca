//
//  Snap.h
//  Scrapboard
//
//  Created by Peter Shih on 5/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Snap : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * userPictureUrl;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSDecimalNumber * lat;
@property (nonatomic, retain) NSNumber * isLiked;
@property (nonatomic, retain) NSString * albumId;
@property (nonatomic, retain) NSDecimalNumber * lng;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSNumber * commentCount;
@property (nonatomic, retain) NSNumber * likeCount;

@end

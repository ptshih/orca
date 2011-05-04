//
//  Album.h
//  Scrapboard
//
//  Created by Peter Shih on 5/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Album : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * isFollowed;
@property (nonatomic, retain) NSString * userPictureUrl;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSDecimalNumber * lat;
@property (nonatomic, retain) NSDecimalNumber * lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * photoCount;
@property (nonatomic, retain) NSString * likeCount;
@property (nonatomic, retain) NSString * commentCount;

@end

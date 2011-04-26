//
//  Album.h
//  Scrapboard
//
//  Created by Peter Shih on 4/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Album : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * participantIds;
@property (nonatomic, retain) NSString * participantFullNames;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * lastActivity;
@property (nonatomic, retain) NSNumber * isFollowed;
@property (nonatomic, retain) NSString * userPictureUrl;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSString * participantFacebookIds;
@property (nonatomic, retain) NSDecimalNumber * lat;
@property (nonatomic, retain) NSDecimalNumber * lng;
@property (nonatomic, retain) NSString * participantFirstNames;
@property (nonatomic, retain) NSString * name;

@end

//
//  Place.h
//  Moogle
//
//  Created by Peter Shih on 4/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Place : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * friendFirstNames;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * pictureUrl;
@property (nonatomic, retain) NSString * friendFullNames;
@property (nonatomic, retain) NSString * friendIds;
@property (nonatomic, retain) NSNumber * activityCount;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * placeId;
@property (nonatomic, retain) NSNumber * hasPhoto;
@property (nonatomic, retain) NSString * authorId;

@end

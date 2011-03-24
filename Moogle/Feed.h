//
//  Feed.h
//  Moogle
//
//  Created by Peter Shih on 3/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Feed : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * authorPictureUrl;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * authorId;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * podId;

@end

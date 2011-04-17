//
//  Event.h
//  Kupo
//
//  Created by Peter Shih on 4/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * authorId;
@property (nonatomic, retain) NSNumber * hasPhoto;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * friendFirstNames;
@property (nonatomic, retain) NSString * friendIds;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSNumber * hasVideo;
@property (nonatomic, retain) NSString * friendFullNames;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tag;

@end

//
//  Event.h
//  Scrapboard
//
//  Created by Peter Shih on 4/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * authorId;
@property (nonatomic, retain) NSString * participantIds;
@property (nonatomic, retain) NSString * participantFullNames;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSString * lastActivity;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSString * participantFacebookIds;
@property (nonatomic, retain) NSString * participantFirstNames;
@property (nonatomic, retain) NSString * authorFacebookId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isFollowed;

@end

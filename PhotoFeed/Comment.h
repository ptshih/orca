//
//  Comment.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comment : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * userPictureUrl;
@property (nonatomic, retain) NSDate * timestamp;

@end

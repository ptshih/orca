//
//  Pod.h
//  Orca
//
//  Created by Peter Shih on 6/15/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pod : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * fromId;
@property (nonatomic, retain) NSString * fromPictureUrl;
@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * participants;
@property (nonatomic, retain) NSDecimalNumber * lat;
@property (nonatomic, retain) NSDecimalNumber * lng;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * unread;

@end

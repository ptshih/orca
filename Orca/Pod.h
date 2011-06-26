//
//  Pod.h
//  Orca
//
//  Created by Peter Shih on 6/25/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pod : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * fromPictureUrl;
@property (nonatomic, retain) NSString * fromId;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSString * participants;
@property (nonatomic, retain) NSString * sequence;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * unread;
@property (nonatomic, retain) NSString * metadata;

- (NSDictionary *)meta;

@end

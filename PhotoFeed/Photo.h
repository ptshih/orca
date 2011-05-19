//
//  Photo.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/18/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album;

@interface Photo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * fromId;
@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSString * picture;
@property (nonatomic, retain) NSString * source;
@property (nonatomic, retain) NSNumber * height;
@property (nonatomic, retain) NSNumber * width;
@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) Album * album;

@end

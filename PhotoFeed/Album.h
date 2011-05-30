//
//  Album.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Album : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * canUpload;
@property (nonatomic, retain) NSString * fromId;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSNumber * count;
@property (nonatomic, retain) NSString * coverPhoto;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * caption;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * objectId;

@end

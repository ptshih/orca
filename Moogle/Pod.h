//
//  Pod.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Pod : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSNumber * checkinCount;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDate * lastActivity;
@property (nonatomic, retain) NSString * pictureUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * commentCount;

@end

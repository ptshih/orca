//
//  Kupo.h
//  Moogle
//
//  Created by Peter Shih on 4/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Kupo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * tagged;
@property (nonatomic, retain) NSNumber * hasVideo;
@property (nonatomic, retain) NSNumber * hasPhoto;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * authorId;
@property (nonatomic, retain) NSString * placeId;
@property (nonatomic, retain) NSString * authorName;
@property (nonatomic, retain) NSNumber * kupoType;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * photoFileName;
@property (nonatomic, retain) NSString * videoFileName;

@end

//
//  Album.h
//  Scrapboard
//
//  Created by Peter Shih on 5/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Album : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * photoCount;
@property (nonatomic, retain) NSString * photoUrls;
@property (nonatomic, retain) NSString * participants;

@end

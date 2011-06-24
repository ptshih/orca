//
//  Message.h
//  Orca
//
//  Created by Peter Shih on 6/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

@interface Message : NSManagedObject <MKAnnotation> {
@private
}
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * podId;
@property (nonatomic, retain) NSString * photoUrl;
@property (nonatomic, retain) NSNumber * lng;
@property (nonatomic, retain) NSString * sequence;
@property (nonatomic, retain) NSString * fromPictureUrl;
@property (nonatomic, retain) NSString * fromId;
@property (nonatomic, retain) NSNumber * photoWidth;
@property (nonatomic, retain) NSNumber * photoHeight;

@end

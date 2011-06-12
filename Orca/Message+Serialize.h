//
//  Message+Serialize.h
//  Orca
//
//  Created by Peter Shih on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface Message (Serialize)

+ (Message *)addMessageWithDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context;

- (Message *)updateMessageWithDictionary:(NSDictionary *)dictionary;

@end

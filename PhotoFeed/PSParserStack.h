//
//  PSParserStack.h
//  PhotoFeed
//
//  Created by Peter Shih on 5/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSParserStackDelegate <NSObject>

- (void)parseFinishedWithResponse:(id)response andUserInfo:(NSDictionary *)userInfo;

@end

@interface PSParserStack : NSObject {
  
}

+ (PSParserStack *)sharedParser;

- (void)parseData:(NSData *)data withDelegate:(id)delegate andUserInfo:(NSDictionary *)userInfo;
- (void)respondToDelegate:(NSDictionary *)payload;

@end

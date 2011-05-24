//
//  LoginDataCenter.h
//  PhotoFeed
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface LoginDataCenter : PSDataCenter {

}

+ (LoginDataCenter *)defaultCenter;

//- (void)startFacebookLogin;
- (void)getFacebookId;
- (void)startSession;
- (void)startRegister;

@end

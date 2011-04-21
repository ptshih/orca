//
//  LoginDataCenter.h
//  Scrapboard
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PSDataCenter.h"

@interface LoginDataCenter : PSDataCenter {

}

//- (void)startFacebookLogin;
- (void)startSession;
- (void)startRegister;

@end

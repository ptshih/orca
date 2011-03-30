//
//  LoginDataCenter.h
//  Moogle
//
//  Created by Peter Shih on 3/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoogleDataCenter.h"

@interface LoginDataCenter : MoogleDataCenter {

}

//- (void)startFacebookLogin;
- (void)startSession;
- (void)startRegister;

@end

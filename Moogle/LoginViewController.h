//
//  LoginViewController.h
//  Moogle
//
//  Created by Peter Shih on 3/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoogleViewController.h"
#import "FBConnect.h"

@interface LoginViewController : MoogleViewController <FBSessionDelegate> {
  Facebook *_facebook;
}

@end

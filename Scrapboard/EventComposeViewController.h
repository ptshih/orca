//
//  EventComposeViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 4/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ComposeViewController.h"

@interface EventComposeViewController : ComposeViewController <UITextFieldDelegate> {
  UITextField *_name;
}

@end

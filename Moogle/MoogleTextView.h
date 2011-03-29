//
//  MoogleTextView.h
//  Moogle
//
//  Created by Peter Shih on 3/28/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MoogleTextView : UITextView {
  UIImageView *_backgroundView;
}

@property (nonatomic, retain) UIImageView *backgroundView;

@end

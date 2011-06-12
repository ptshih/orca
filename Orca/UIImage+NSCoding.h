//
//  UIImage+NSCoding.h
//  Orca
//
//  Created by Peter Shih on 5/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageNSCoding <NSCoding>

- (id)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
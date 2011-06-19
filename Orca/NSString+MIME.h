//
//  NSString+MIME.h
//  Orca
//
//  Created by Peter Shih on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (NSString_MIME)

+ (NSString *)MIMETypeForExtension:(NSString *)extension;

@end

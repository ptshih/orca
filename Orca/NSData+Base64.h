//
//  NSData+Base64.h
//  Orca
//
//  Created by Peter Shih on 6/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@interface NSData (NSData_Base64)

- (NSString *)base64md5String;
- (NSString *)base64EncodedString;
- (NSString *)signedHMACStringWithKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm;

@end

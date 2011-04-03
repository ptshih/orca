//
//  KupoComposeDataCenter.h
//  Moogle
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoogleDataCenter.h"

@interface KupoComposeDataCenter : MoogleDataCenter {

}

- (void)sendKupoComposeWithPlaceId:(NSString *)placeId andComment:(NSString *)comment andImage:(UIImage *)image;

- (void)sendCheckinComposeWithPlaceId:(NSString *)placeId andComment:(NSString *)comment andImage:(UIImage *)image;

@end

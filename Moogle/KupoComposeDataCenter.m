//
//  KupoComposeDataCenter.m
//  Moogle
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "KupoComposeDataCenter.h"


@implementation KupoComposeDataCenter

- (void)sendKupoComposeWithPlaceId:(NSString *)placeId andComment:(NSString *)comment andImage:(UIImage *)image {
  NSURL *kupoComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/kupos/new", MOOGLE_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  BOOL hasImage = NO;
  
  if ([comment length] > 0) {
    [params setValue:comment forKey:@"comment"];
  }
  if (image) {
    [params setValue:image forKey:@"image"];
    hasImage = YES;
  }
  [params setValue:placeId forKey:@"place_id"];
  [params setValue:[NSString stringWithFormat:@"%0.0f", [[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
  
  [self sendOperationWithURL:kupoComposeUrl andMethod:POST andHeaders:nil andParams:params isFormData:hasImage];
}

- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [super dataCenterFailedWithOperation:operation];
}

@end

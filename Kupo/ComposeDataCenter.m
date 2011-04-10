//
//  ComposeDataCenter.m
//  Kupo
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeDataCenter.h"
#import "KupoLocation.h"

static ComposeDataCenter *_defaultCenter = nil;

@implementation ComposeDataCenter

#pragma mark -
#pragma mark Shared Instance
+ (id)defaultCenter {
  @synchronized(self) {
    if (_defaultCenter == nil) {
      _defaultCenter = [[self alloc] init];
    }
    return _defaultCenter;
  }
}

- (void)sendKupoComposeWithPlaceId:(NSString *)placeId andComment:(NSString *)comment andImage:(UIImage *)image andVideo:(NSData *)video {
  NSURL *kupoComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/kupos/new", KUPO_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:@"1" forKey:@"kupo_type"];
  [params setValue:placeId forKey:@"place_id"];
  
  if ([comment length] > 0) {
    [params setValue:comment forKey:@"comment"];
  }
  
  NetworkOperationAttachmentType attachmentType = NetworkOperationAttachmentTypeNone;
  
  if (image) {
    [params setValue:image forKey:@"image"];
    if (video) {
      [params setValue:video forKey:@"video"];
      attachmentType = NetworkOperationAttachmentTypeMP4;
    } else {
      attachmentType = NetworkOperationAttachmentTypeJPEG;
    }
  }
  
  [self sendOperationWithURL:kupoComposeUrl andMethod:POST andHeaders:nil andParams:params andAttachmentType:attachmentType];
}

- (void)sendCheckinComposeWithPlaceId:(NSString *)placeId andComment:(NSString *)comment andImage:(UIImage *)image andVideo:(NSData *)video {
  // params[:message], params[:place], params[:lat], params[:lng], params[:tags]
  
  NSURL *checkinComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/checkins/new", KUPO_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:@"0" forKey:@"kupo_type"];
  
  [params setValue:placeId forKey:@"place_id"];
  
  // Location
  CGFloat lat = [[KupoLocation sharedInstance] latitude];
  CGFloat lng = [[KupoLocation sharedInstance] longitude];
  [params setObject:[NSString stringWithFormat:@"%f", lat] forKey:@"lat"];
  [params setObject:[NSString stringWithFormat:@"%f", lng] forKey:@"lng"];
  
  if ([comment length] > 0) {
    [params setValue:comment forKey:@"comment"];
  }

  NetworkOperationAttachmentType attachmentType = NetworkOperationAttachmentTypeNone;
  
  if (image) {
    [params setValue:image forKey:@"image"];
    if (video) {
      [params setValue:video forKey:@"video"];
      attachmentType = NetworkOperationAttachmentTypeMP4;
    } else {
      attachmentType = NetworkOperationAttachmentTypeJPEG;
    }
  }
  
  [self sendOperationWithURL:checkinComposeUrl andMethod:POST andHeaders:nil andParams:params andAttachmentType:attachmentType];
}

- (void)dataCenterFinishedWithOperation:(LINetworkOperation *)operation {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadController object:nil];
  [super dataCenterFinishedWithOperation:operation];
}

- (void)dataCenterFailedWithOperation:(LINetworkOperation *)operation {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadController object:nil];
  [super dataCenterFailedWithOperation:operation];
}

@end

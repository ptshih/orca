//
//  ComposeDataCenter.m
//  Scrapboard
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

- (void)sendEventComposeWithEventName:(NSString *)eventName andEventTag:(NSString *)eventTag andMessage:(NSString *)message andImage:(UIImage *)image andVideo:(NSData *)video {
  NSURL *eventComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/events/new", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:eventName forKey:@"name"];
  if (eventTag) [params setValue:eventTag forKey:@"tag"];
  [params setValue:@"#scrapboard for iPhone" forKey:@"source"];
  
  if ([message length] > 0) {
    [params setValue:message forKey:@"message"];
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
  
  [self sendOperationWithURL:eventComposeUrl andMethod:POST andHeaders:nil andParams:params andAttachmentType:attachmentType];
}

- (void)sendKupoComposeWithEventId:(NSString *)eventId andMessage:(NSString *)message andImage:(UIImage *)image andVideo:(NSData *)video {
  NSURL *kupoComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/kupos/new", API_BASE_URL]];
  
//  :source => params[:source],
//  :event_id => params[:event_id],
//  :user_id => @current_user.id,
//  :facebook_place_id => params[:facebook_place_id],
//  :facebook_checkin_id => params[:facebook_checkin_id],
//  :message => params[:message],
//  :photo => params[:image],
//  :video => params[:video],
//  :has_photo => params[:image].nil? ? false : true,
//  :has_video => params[:video].nil? ? false : true,
//  :lat => params[:lat].nil? ? params[:lat] : nil,
//  :lng => params[:lng].nil? ? params[:lng] : nil
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:eventId forKey:@"event_id"];
  [params setValue:@"#scrapboard for iPhone" forKey:@"source"];
  
  if ([message length] > 0) {
    [params setValue:message forKey:@"message"];
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

- (void)sendCheckinComposeWithEventId:(NSString *)eventId andComment:(NSString *)comment andImage:(UIImage *)image andVideo:(NSData *)video {
  // params[:message], params[:event], params[:lat], params[:lng], params[:tags]
  
  NSURL *checkinComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/checkins/new", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:@"0" forKey:@"kupo_type"];
  
  [params setValue:eventId forKey:@"event_id"];
  
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

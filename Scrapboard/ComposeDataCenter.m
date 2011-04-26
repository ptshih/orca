//
//  ComposeDataCenter.m
//  Scrapboard
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeDataCenter.h"
#import "KupoLocation.h"

@implementation ComposeDataCenter

- (void)sendEventComposeWithEventName:(NSString *)eventName andEventTag:(NSString *)eventTag andMessage:(NSString *)message andImage:(UIImage *)image andVideo:(NSData *)video {
  NSURL *eventComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/events/new", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:eventName forKey:@"name"];
  if (eventTag) [params setValue:eventTag forKey:@"tag"];
  [params setValue:@"#scrapboard for iPhone" forKey:@"source"];
  
  if ([message length] > 0) {
    [params setValue:message forKey:@"message"];
  }
  
  if (image) {
    [params setValue:image forKey:@"image"];
    if (video) {
      [params setValue:video forKey:@"video"];
    } else {
    }
  }
  
  [self sendFormRequestWithURL:eventComposeUrl andHeaders:nil andParams:params andFile:nil andUserInfo:nil];
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
  
  if (image) {
    [params setValue:image forKey:@"image"];
    if (video) {
      [params setValue:video forKey:@"video"];
    } else {
    }
  }

  [self sendFormRequestWithURL:kupoComposeUrl andHeaders:nil andParams:params andFile:nil andUserInfo:nil];
}

- (void)dataCenterRequestFinished:(ASIHTTPRequest *)request withResponse:(id)response {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadController object:nil];
  [super dataCenterRequestFinished:request withResponse:response];
}

- (void)dataCenterRequestFailed:(ASIHTTPRequest *)request withError:(NSError *)error {
  [[NSNotificationCenter defaultCenter] postNotificationName:kReloadController object:nil];
  [super dataCenterRequestFailed:request withError:error];
}

@end

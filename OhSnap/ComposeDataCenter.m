//
//  ComposeDataCenter.m
//  OhSnap
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeDataCenter.h"

static ComposeDataCenter *_sharedInstance = nil;

@implementation ComposeDataCenter

+ (id)sharedInstance {
  if (_sharedInstance == nil) {
    _sharedInstance = [[self alloc] init];
  }
  return _sharedInstance;
}

- (void)sendSnapWithAlbumId:(NSString *)albumId andMessage:(NSString *)message andPhoto:(UIImage *)photo shouldShare:(BOOL)shouldShare {
  NSURL *snapComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/snaps", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:albumId forKey:@"album_id"];
  [params setValue:message forKey:@"message"];
  [params setValue:@"photo" forKey:@"media_type"];
  [params setValue:[NSNumber numberWithBool:shouldShare] forKey:@"should_share"];
  
  NSData *imageData = nil;
  imageData = UIImageJPEGRepresentation(photo, 0.8);
  
  NSDictionary *file = [NSDictionary dictionaryWithObjectsAndKeys:imageData, @"fileData", @"photo.jpg", @"fileName", @"image/jpeg", @"fileContentType", @"photo", @"fileKey", nil];
  
  [self sendFormRequestWithURL:snapComposeUrl andHeaders:nil andParams:params andFile:file andUserInfo:nil];
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

//
//  ComposeDataCenter.m
//  Scrapboard
//
//  Created by Peter Shih on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeDataCenter.h"

@implementation ComposeDataCenter

- (void)sendSnapWithAlbumId:(NSString *)albumId andMessage:(NSString *)message andPhoto:(UIImage *)photo shouldShare:(BOOL)shouldShare {
  NSURL *snapComposeUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/snaps", API_BASE_URL]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [params setValue:albumId forKey:@"album_id"];
  [params setValue:message forKey:@"message"];
  [params setValue:[NSNumber numberWithBool:shouldShare] forKey:@"should_share"];
  
  NSDictionary *file = [NSDictionary dictionaryWithObjectsAndKeys:photo, @"fileData", @"photo.jpg", @"fileName", @"image/jpeg", @"fileContentType", @"photo", @"fileKey", nil];
  
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

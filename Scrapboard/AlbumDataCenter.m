//
//  AlbumDataCenter.m
//  Scrapboard
//
//  Created by Peter Shih on 4/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AlbumDataCenter.h"


@implementation AlbumDataCenter

- (void)getAlbums {
  NSURL *albumsUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", API_BASE_URL, @"albums"]];
  
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  
  [self sendRequestWithURL:albumsUrl andMethod:GET andHeaders:nil andParams:params andUserInfo:nil];
}

@end

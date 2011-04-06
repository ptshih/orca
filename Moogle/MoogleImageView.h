//
//  MoogleImageView.h
//  Moogle
//
//  Created by Peter Shih on 3/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LINetworkOperationDelegate.h"
#import "MoogleImageViewDelegate.h"
#import "Constants.h"

@interface MoogleImageView : UIImageView <LINetworkOperationDelegate, MoogleImageViewDelegate> {
  NSString *_urlPath;
  
  LINetworkOperation *_op;
  id <MoogleImageViewDelegate> _delegate;
}

@property (nonatomic, copy) NSString *urlPath;
@property (nonatomic, assign) id <MoogleImageViewDelegate> delegate;

- (void)loadImage;
- (void)unloadImage;
- (void)imageDidLoad;

@end

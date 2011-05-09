//
//  CameraViewController.h
//  Scrapboard
//
//  Created by Peter Shih on 5/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSViewController.h"

@interface CameraViewController : PSViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
  UIImage *_snappedImage;
  
  BOOL _shouldSaveToAlbum;
  BOOL _shouldDismissOnAppear;
}

- (void)showCamera;
- (void)showPhotoLibrary;
- (void)snap;

@end

//
//  EventCell.h
//  Scrapboard
//
//  Created by Peter Shih on 3/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSImageCell.h"
#import "Event.h"

@interface EventCell : PSImageCell {
  UILabel *_tagLabel;
  UILabel *_nameLabel;
  UILabel *_lastActivityLabel;
  UILabel *_participantsLabel;
  UILabel *_timestampLabel;
  
  Event *_event;
  NSMutableArray *_participantPictureArray;
  NSMutableArray *_participantIds;
}

- (void)loadParticipantPictures;

@end

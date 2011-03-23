//
//  HeaderTabView.m
//  Moogle
//
//  Created by Peter Shih on 3/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HeaderTabView.h"
#import "Constants.h"

#define BUTTON_HEIGHT 29.0
#define BUTTON_SPACING 5.0

static UIImage *_btnNormal;
static UIImage *_btnSelected;

@interface HeaderTabView (Private)

- (void)selectButton:(id)sender;

@end

@implementation HeaderTabView

@synthesize buttons = _buttons;
@synthesize delegate = _delegate;

+ (void)initialize {
  _btnNormal = [[[UIImage imageNamed:@"btn_filter.png"] stretchableImageWithLeftCapWidth:37 topCapHeight:14] retain];
  _btnSelected = [[[UIImage imageNamed:@"btn_filter_selected.png"] stretchableImageWithLeftCapWidth:37 topCapHeight:14] retain];
}

- (id)initWithFrame:(CGRect)frame andButtonTitles:(NSArray *)titles {
  self = [super initWithFrame:frame];
  if (self) {
    _buttons = [[NSMutableArray array] retain];
    
    NSUInteger numButtons = [titles count];
    CGFloat spacing = (numButtons + 1) * BUTTON_SPACING;
    CGFloat buttonWidth = floor((frame.size.width - spacing) / numButtons);
    
    UIButton *button = nil;
    int i = 0;
    for (NSString *title in titles) {
      button = [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_SPACING + (buttonWidth * i) + (BUTTON_SPACING * i), 8.0, buttonWidth, BUTTON_HEIGHT)];
      
      button.adjustsImageWhenHighlighted = NO;
      [button setBackgroundImage:_btnNormal forState:UIControlStateNormal];
      [button setBackgroundImage:_btnSelected forState:UIControlStateSelected];
      [button setBackgroundImage:_btnSelected forState:UIControlStateHighlighted];
      
      [button setTitle:title forState:UIControlStateNormal];
      [button setTitleColor:FILTER_COLOR_BLUE forState:UIControlStateNormal];
      button.titleLabel.font = [UIFont boldSystemFontOfSize:12];
      button.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
      
      [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
      [self.buttons addObject:button];
      [self addSubview:button];
      [button release];
      
      i++;
    }
  }
  return self;
}

- (void)selectButton:(id)sender {
  NSNumber *buttonIndex = [NSNumber numberWithInteger:[self.buttons indexOfObject:sender]];
  for (UIButton *button in self.buttons) {
    [button setSelected:NO];
  }
  [[self.buttons objectAtIndex:[buttonIndex integerValue]] setSelected:YES];
  
  // Inform delegate
  if (self.delegate) {
    [self.delegate retain];
    if ([self.delegate respondsToSelector:@selector(tabSelectedAtIndex:)]) {
      [self.delegate performSelector:@selector(tabSelectedAtIndex:) withObject:buttonIndex];
    }
    [self.delegate release];
  }
}

- (void)setSelectedForTabAtIndex:(NSInteger)index {
  [[self.buttons objectAtIndex:index] setSelected:YES];
  [self selectButton:[self.buttons objectAtIndex:index]];
}

- (void)dealloc {
  [super dealloc];
}

@end

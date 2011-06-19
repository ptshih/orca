//
//  ConfigViewController.m
//  Orca
//
//  Created by Peter Shih on 6/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "ConfigDataCenter.h"
#import "Pod.h"
#import "UserCell.h"
#import "PSAlertCenter.h"

@implementation ConfigViewController

@synthesize pod = _pod;

- (id)init {
  self = [super init];
  if (self) {
    [[ConfigDataCenter defaultCenter] setDelegate:self];
  }
  return self;
}

- (void)loadView {
  [super loadView];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupBackgroundWithImage:[UIImage imageNamed:@"bg-weave.png"]];
  [self addButtonWithTitle:@"Done" andSelector:@selector(dismiss) isLeft:NO type:PSBarButtonTypeBlue];

  _navTitleLabel.text = @"Configure Pod";
  
  // Table
  [self setupTableViewWithFrame:self.view.bounds andStyle:UITableViewStylePlain andSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
  
  [self setupFooter];
  
  [[ConfigDataCenter defaultCenter] getMembersForPodId:_pod.id];
}

- (void)setupFooter {
  UIView *footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
  
  _muteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
  _muteButton.frame = CGRectMake(10, 7, 145, 30);
  [_muteButton setBackgroundImage:[[UIImage imageNamed:@"navbar_blue_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
  [_muteButton setBackgroundImage:[[UIImage imageNamed:@"navbar_blue_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateHighlighted];
  if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"podMutedUntil_%@", _pod.id]]) {
    [_muteButton setTitle:@"Unmute Pod" forState:UIControlStateNormal];
  } else {
    [_muteButton setTitle:@"Mute Pod" forState:UIControlStateNormal];
  }
  [_muteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [_muteButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
  _muteButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
  _muteButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
  [_muteButton addTarget:self action:@selector(mute) forControlEvents:UIControlEventTouchUpInside];
  [footerView addSubview:_muteButton];
  
  UIButton *leaveButton = [UIButton buttonWithType:UIButtonTypeCustom];
  leaveButton.frame = CGRectMake(165, 7, 145, 30);
  [leaveButton setBackgroundImage:[[UIImage imageNamed:@"navbar_red_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
  [leaveButton setBackgroundImage:[[UIImage imageNamed:@"navbar_red_highlighted_button.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateHighlighted];
  [leaveButton setTitle:@"Leave Pod" forState:UIControlStateNormal];
  [leaveButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
  [leaveButton setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
  leaveButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
  leaveButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
  [leaveButton addTarget:self action:@selector(leave) forControlEvents:UIControlEventTouchUpInside];
  [footerView addSubview:leaveButton];
  
  footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationbar_bg.png"]];
  
  [self setupFooterWithView:footerView];
}

- (void)setupTableHeader {
  UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 60)] autorelease];
  headerView.backgroundColor = [UIColor darkGrayColor];
  
  // Pod Name
  UILabel *podNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 18)];
  podNameLabel.backgroundColor = [UIColor clearColor];
  podNameLabel.textColor = [UIColor whiteColor];
  podNameLabel.font = TITLE_FONT;
  podNameLabel.text = @"Pod Name (tap to rename)";
  [headerView addSubview:podNameLabel];
  
  UITextField *podNameField = [[[UITextField alloc] initWithFrame:CGRectMake(10, 25, 300, 27)] autorelease];
  podNameField.placeholder = [NSString stringWithFormat:@"%@", _pod.name];
  podNameField.borderStyle = UITextBorderStyleRoundedRect;
  podNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
  podNameField.returnKeyType = UIReturnKeyDone;
  podNameField.delegate = self;
  [headerView addSubview:podNameField];
  
  self.tableView.tableHeaderView = headerView;
}

- (void)setupTableFooter {
  UIImageView *footerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"table_footer_background.png"]];
  _tableView.tableFooterView = footerImage;
  [footerImage release];
}

#pragma mark - Actions
- (void)mute {
  if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"podMutedUntil_%@", _pod.id]]) {
    // unmute
    [[ConfigDataCenter defaultCenter] mutePodForPodId:_pod.id forDuration:0];
    
    [_muteButton setTitle:@"Mute Pod" forState:UIControlStateNormal];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"podMutedUntil_%@", _pod.id]];
    [[NSUserDefaults standardUserDefaults] synchronize];
  } else {
    UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:@"Mute Pod" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Mute Forever" otherButtonTitles:@"Mute for 1 hour", nil] autorelease];
    [as showInView:self.view];
  }
}

- (void)leave {
  [[[[UIAlertView alloc] initWithTitle:@"Leave Pod?" message:@"Are you sure you want to leave this pod? You can always have a friend invite you back. CURRENTLY DOES NOT WORK" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"Nevermind", nil] autorelease] show];
}

- (void)dismiss {
  [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  textField.placeholder = nil;
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  textField.placeholder = textField.text;
  textField.text = nil;
  return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark - Table Stuff
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [_sectionTitles objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSDictionary *userDict = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  return [UserCell rowHeightForObject:userDict forInterfaceOrientation:[self interfaceOrientation]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UserCell *cell = nil;
  NSString *reuseIdentifier = [UserCell reuseIdentifier];
  
  cell = (UserCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
  }
  
  // Configure Cell
  NSDictionary *userDict = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  [cell fillCellWithObject:userDict];
  
  return cell;
}

#pragma mark - Data Center Delegate
- (void)dataCenterDidFinish:(ASIHTTPRequest *)request withResponse:(id)response {
  NSString *action = [request.userInfo objectForKey:@"action"];
  
  if ([action isEqualToString:@"members"]) {
    [_sectionTitles removeAllObjects];
    [_sectionTitles addObject:@"Pod Members"];
    
    [self.items removeAllObjects];
    [self.items addObject:response];
    [self.tableView reloadData];
    [self updateState];
  }
}

- (void)dataCenterDidFail:(ASIHTTPRequest *)request withError:(NSError *)error {
  [self.tableView reloadData];
  [self updateState];
}

#pragma mark - Alert
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex != alertView.cancelButtonIndex) {
    // leave pod
  } else {
    // nevermind
  }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (buttonIndex != actionSheet.cancelButtonIndex) {
    NSTimeInterval duration = 0;
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
      duration = [[NSDate distantFuture] timeIntervalSinceDate:[NSDate date]];
    } else {
      duration = 3600;
    }
    
    [[ConfigDataCenter defaultCenter] mutePodForPodId:_pod.id forDuration:(duration/3600)];
    
    [_muteButton setTitle:@"Unmute Pod" forState:UIControlStateNormal];
    
    NSDate *mutedUntil = [NSDate dateWithTimeInterval:duration sinceDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:mutedUntil forKey:[NSString stringWithFormat:@"podMutedUntil_%@", _pod.id]];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
}

- (void)dealloc {
  [[ConfigDataCenter defaultCenter] setDelegate:nil];
  RELEASE_SAFELY(_muteButton);
  [super dealloc];
}

@end

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "substrate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <instabetterprefs/InstaBetterPrefs.h>
#import <lib/NYTPhotosViewController.h>
#import "IGHeaders.h"
#import <lib/MBProgressHUD.h>
#import <lib/UIAlertView+Blocks.h>
#import <notify.h>
#import <MapKit/MapKit.h>
#import "InstaHelper.h"

#define ibBundle @"/Library/Application Support/InstaBetter"
NSBundle *bundle = [[NSBundle alloc] initWithPath:ibBundle];

static NSMutableArray *muted = nil;
static NSMutableDictionary *likesDict = [[NSMutableDictionary alloc] init];

static BOOL enabled = YES;
static BOOL showPercents = YES;
static BOOL hideSponsored = YES;
static int muteMode = 0;
static BOOL muteActivity = YES;
static BOOL saveActions = YES;
static BOOL followStatus = YES;
static BOOL customLocations = YES;
static BOOL openInApp = YES;
static BOOL disableDMRead = NO;
static BOOL loadHighRes = NO;
static BOOL mainGrid = NO;
static BOOL returnKey = NO;
static BOOL layoutSwitcher = YES;
static int audioMode = 1;
static int videoMode = 1;
static int alertMode = 1;
static int saveMode = 1;
static int saveConfirm = YES;
static int fakeFollowers = nil;
static int fakeFollowing = nil;
static BOOL enableTimestamps = YES;
static int timestampFormat = 0;
static BOOL alwaysTimestamp = NO;
static BOOL accountSwitcher = YES;
static UIBarButtonItem* gridItem;
static UIBarButtonItem* listItem;

static BOOL notificationsEnabled = YES;
static NSString* notificationsLike = nil;
static NSString* notificationsComment = nil;
static NSString* notificationsNewFollower = nil;
static NSString* notificationsRequestApproved = nil;
static NSString* notificationsFollowRequest = nil;
static NSString* notificationsUsertag = nil;
static NSString* notificationsDirect = nil;

IGFeedItem *cachedItem = nil;

float origPosition = nil;
int ringerState;
static BOOL ringerMuted;

static NSString* localizedString(NSString* key) {
  return [bundle localizedStringForKey:key value:@"" table:nil];
}

static NSString *instaMute = localizedString(@"MUTE");
static NSString *instaUnmute = localizedString(@"UNMUTE");
static NSString *instaSave = localizedString(@"SAVE_MEDIA");
static NSString *prefsLoc = @"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist";

static NSDictionary* loadPrefs() {
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:prefsLoc];

  if (exists) {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
    if (prefs) {
      enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
      hideSponsored = [prefs objectForKey:@"hide_sponsored"] ? [[prefs objectForKey:@"hide_sponsored"] boolValue] : YES;

      followStatus = [prefs objectForKey:@"follow_status"] ? [[prefs objectForKey:@"follow_status"] boolValue] : YES;
      showPercents = [prefs objectForKey:@"show_percents"] ? [[prefs objectForKey:@"show_percents"] boolValue] : YES;
      customLocations = [prefs objectForKey:@"custom_locations"] ? [[prefs objectForKey:@"custom_locations"] boolValue] : YES;
      returnKey = [prefs objectForKey:@"return_key"] ? [[prefs objectForKey:@"return_key"] boolValue] : NO;
      openInApp = [prefs objectForKey:@"app_browser"] ? [[prefs objectForKey:@"app_browser"] boolValue] : YES;
      disableDMRead = [prefs objectForKey:@"disable_read_notification"] ? [[prefs objectForKey:@"disable_read_notification"] boolValue] : NO;
      loadHighRes = [prefs objectForKey:@"zoom_hi_res"] ? [[prefs objectForKey:@"zoom_hi_res"] boolValue] : NO;

      mainGrid = [prefs objectForKey:@"main_grid"] ? [[prefs objectForKey:@"main_grid"] boolValue] : NO;
      layoutSwitcher = [prefs objectForKey:@"layout_switcher"] ? [[prefs objectForKey:@"layout_switcher"] boolValue] : YES;

      muteMode = [prefs objectForKey:@"mute_mode"] ? [[prefs objectForKey:@"mute_mode"] intValue] : 0;
      muteActivity = [prefs objectForKey:@"mute_activity"] ? [[prefs objectForKey:@"mute_activity"] boolValue] : YES;
      muted = [prefs objectForKey:@"muted_users"] ? [prefs objectForKey:@"muted_users"] : [[NSMutableArray alloc] init];

      alertMode = [prefs objectForKey:@"alert_mode"] ? [[prefs objectForKey:@"alert_mode"] intValue] : 1;
      accountSwitcher = [prefs objectForKey:@"account_switcher"] ? [[prefs objectForKey:@"account_switcher"] boolValue] : YES;

      saveActions = [prefs objectForKey:@"save_actions"] ? [[prefs objectForKey:@"save_actions"] boolValue] : YES;
      saveMode = [prefs objectForKey:@"save_mode"] ? [[prefs objectForKey:@"save_mode"] intValue] : 1;
      saveConfirm = [prefs objectForKey:@"save_confirm"] ? [[prefs objectForKey:@"save_confirm"] boolValue] : YES;

      // video and audio
      audioMode = [prefs objectForKey:@"audio_mode"] ? [[prefs objectForKey:@"audio_mode"] intValue] : 1;
      videoMode = [prefs objectForKey:@"video_mode"] ? [[prefs objectForKey:@"video_mode"] intValue] : 1;

      // spoofing
      fakeFollowers = [prefs objectForKey:@"fake_follower_count"] ? [[prefs objectForKey:@"fake_follower_count"] intValue] : nil;
      fakeFollowing = [prefs objectForKey:@"fake_following_count"] ? [[prefs objectForKey:@"fake_following_count"] intValue] : nil;

      // timestamps
      alwaysTimestamp = [prefs objectForKey:@"always_timestamp"] ? [[prefs objectForKey:@"always_timestamp"] boolValue] : NO;
      enableTimestamps = [prefs objectForKey:@"enable_timestamp"] ? [[prefs objectForKey:@"enable_timestamp"] boolValue] : YES;
      timestampFormat = [prefs objectForKey:@"timestamp_format"] ? [[prefs objectForKey:@"timestamp_format"] intValue] : 0;

      // notifications
      notificationsEnabled = [prefs objectForKey:@"notifications_enabled"] ? [[prefs objectForKey:@"notifications_enabled"] boolValue] : YES;
      notificationsLike = [prefs objectForKey:@"notifications_like"] ? [prefs objectForKey:@"notifications_like"] : nil;
      notificationsComment = [prefs objectForKey:@"notifications_comment"] ? [prefs objectForKey:@"notifications_comment"] : nil;
      notificationsNewFollower = [prefs objectForKey:@"notifications_new_follower"] ? [prefs objectForKey:@"notifications_new_follower"] : nil;
      notificationsFollowRequest = [prefs objectForKey:@"notifications_follow_request"] ? [prefs objectForKey:@"notifications_follow_request"] : nil;
      notificationsRequestApproved = [prefs objectForKey:@"notifications_request_approved"] ? [prefs objectForKey:@"notifications_request_approved"] : nil;
      notificationsUsertag = [prefs objectForKey:@"notifications_usertag"] ? [prefs objectForKey:@"notifications_usertag"] : nil;
      notificationsDirect = [prefs objectForKey:@"notifications_direct"] ? [prefs objectForKey:@"notifications_direct"] : nil;

      return prefs;
    }
  }
  muted = [[NSMutableArray alloc] init];

  return nil;
}

static NSString * highestResImage(NSDictionary *versions) {
  CGFloat highestCount = 0;
  NSString *highestURL = nil;
  for (NSDictionary *ver in versions) {
    CGFloat height = [[ver objectForKey:@"height"] floatValue];
    CGFloat width = [[ver objectForKey:@"width"] floatValue];
    CGFloat pixelCount = height * width;

    if (pixelCount >= highestCount) {
      highestCount = pixelCount;
      highestURL = [ver objectForKey:@"url"];
    }
  }
  return highestURL;
}

static void saveVideo(NSURL *vidURL, MBProgressHUD *status) {
  if (!status) {
    UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
    status = [MBProgressHUD showHUDAddedTo:appWindow animated:YES];
    status.labelText = @"Saving";
  }
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSURLRequest *request = [NSURLRequest requestWithURL:vidURL];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
      NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
      NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[vidURL lastPathComponent]];
      [data writeToURL:tempURL atomically:NO];
      [%c(IGAssetWriter) writeVideoToInstagramAlbum:tempURL completionBlock:nil];
      dispatch_async(dispatch_get_main_queue(), ^{
        status.customView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"37x-Checkmark@2x" ofType:@"png"]]];
        status.mode = MBProgressHUDModeCustomView;
        status.labelText = localizedString(@"SAVED");

        [status hide:YES afterDelay:1.0];
      });
    }];
  });
}

static void saveImage(NSURL *imgUrl, MBProgressHUD *status) {
  if (!status) {
    UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
    status = [MBProgressHUD showHUDAddedTo:appWindow animated:YES];
    status.labelText = localizedString(@"SAVING");
  }
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
    UIImage *img = [UIImage imageWithData:imgData];
    IGAssetWriter *postImageAssetWriter = [[%c(IGAssetWriter) alloc] initWithImage:img metadata:nil];
    [postImageAssetWriter writeToInstagramAlbum];
    dispatch_async(dispatch_get_main_queue(), ^{
      status.customView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"37x-Checkmark@2x" ofType:@"png"]]];
      status.mode = MBProgressHUDModeCustomView;
      status.labelText = localizedString(@"SAVED");

      [status hide:YES afterDelay:1.0];
    });
  });
}

static void saveMedia(IGPost *post) {
  if (enabled && saveActions) {
    UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *status = [MBProgressHUD showHUDAddedTo:appWindow animated:YES];
    status.labelText = localizedString(@"SAVING");
    if (post.mediaType == 1) {
      NSString *versionURL = highestResImage(post.photo.imageVersions);
    
      NSURL *imgURL = [NSURL URLWithString:versionURL];
      saveImage(imgURL, status);

    } else if (post.mediaType == 2) {
      NSString *versionURL = highestResImage(post.video.videoVersions);
    
      NSURL *vidURL = [NSURL URLWithString:versionURL];
      saveVideo(vidURL, status);
    }
  }
}

// show timestamps on IGFeedItems
// header - IGFeedItemheader for relevant IGFeedItem
// animated - whether or not displaying the timestamp should be animated
static void showTimestamp(IGFeedItemHeader *header, BOOL animated) {
  NSDate *takenAt = [header.feedItem.takenAt date];

  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

  NSDateFormatterStyle style = nil;
  if (timestampFormat == 0) {
    style = NSDateFormatterShortStyle;
  } else if (timestampFormat == 1) {
    style = NSDateFormatterMediumStyle;
  } else if (timestampFormat == 2) {
    style = NSDateFormatterLongStyle;
  }

  [formatter setTimeStyle:style];
  [formatter setDateStyle:style];

  NSString *timestamp = [formatter stringFromDate:takenAt];
  float old = header.timestampLabel.frame.size.width;
  float oldY = header.timestampLabel.frame.origin.y;
  float oldHeight = header.timestampLabel.frame.size.height;
  CGSize size = [timestamp sizeWithAttributes:[NSDictionary dictionaryWithObject:header.timestampLabel.font forKey:NSFontAttributeName]];

  float cur = size.width;

  float change = cur - old;
  float newX = header.timestampLabel.frame.origin.x - change;

  if (animated) {
    [UIView animateWithDuration:0.5 
      animations:^{
        header.timestampLabel.text = timestamp;
        [header.timestampLabel setFrame:CGRectMake(newX, 
          oldY,
          header.timestampLabel.frame.size.width + change,
          oldHeight)];
      }
      completion:nil];
  } else {
    header.timestampLabel.text = timestamp;
    [header.timestampLabel setFrame:CGRectMake(newX, 
      oldY,
      header.timestampLabel.frame.size.width + change,
      oldHeight)];
  }
}

@implementation InstaBetterPhoto
@end

@implementation LocationSelectorViewController
- (void)viewDidLoad {
  [super viewDidLoad];
  self.view = [[UIView alloc] initWithFrame: [[UIScreen mainScreen] applicationFrame]];
  self.view.backgroundColor = [UIColor whiteColor];

  self.title = localizedString(@"SELECT_LOCATION");
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideSelection)];
  [self.navigationItem setLeftBarButtonItem:doneButton];

  self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];

  UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(selectedLocation:)];
  [longPress setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];
  [longPress setMinimumPressDuration:0.75];
  [self.mapView addGestureRecognizer:longPress];

  [self.view addSubview:self.mapView];
}

- (void)selectedLocation:(UITapGestureRecognizer *)recognizer {
  if (recognizer.state != UIGestureRecognizerStateBegan) return;
  [self.mapView removeAnnotations:self.mapView.annotations];

  CGPoint point = [recognizer locationInView:self.mapView];
  CLLocationCoordinate2D tapPoint = [self.mapView convertPoint:point toCoordinateFromView:self.mapView];

  MKPointAnnotation *loc = [[MKPointAnnotation alloc] init]; 
  loc.coordinate = tapPoint;
  loc.title = localizedString(@"SELECTED_LOCATION");

  [self.mapView addAnnotation:loc];
}

- (void)hideSelection {
  if (self.delegate) {
    MKPointAnnotation *annotation = [self.mapView.annotations firstObject];
    if (annotation) {
      [self.delegate didSelectLocation:annotation.coordinate];
    }
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}
@end

%group instaHooks

// add return key to Instagram caption
%hook IGCaptionCell
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  BOOL ori = %orig;
  if (!(enabled && returnKey)) return ori;
  [textView setKeyboardType:0];
  [textView setReturnKeyType:UIReturnKeyDefault];
  return ori;
}
%end

// add return key to comments

%hook IGCommentThreadViewController
- (BOOL)growingTextViewShouldReturn:(id)textView {
  if (!(enabled && returnKey)) return %orig;
  return YES;
}
- (BOOL)growingTextView:(id)textView shouldChangeTextInRange:(NSRange)range replacementText:(id)text {
  if (!(enabled && returnKey)) return %orig;
  return YES;
}
%end

%hook IGGrowingTextView
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
  BOOL ori = %orig;
  if (!(enabled && returnKey)) return ori;
  [textView setKeyboardType:0];
  [textView setReturnKeyType:UIReturnKeyDefault];
  [self setMaxNumberOfLines:30];
  textView.textContainer.maximumNumberOfLines = 10;
  return ori;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
  if (!(enabled && returnKey)) return %orig;
  return YES;
}
%end

// double-tap like confirmation

%hook IGFeedItemVideoView
- (void)onDoubleTap:(UITapGestureRecognizer *)tap {
  if (enabled) {
    IGPost *post = ((IGFeedItemVideoView *)[tap view]).post;
    NSDate *now = [NSDate date];
    BOOL needsAlert = [now timeIntervalSinceDate:[post.takenAt date]] > 86400.0f;
    if (!post.hasLiked && (alertMode == 2 || (alertMode == 1 && needsAlert))) {
      [UIAlertView showWithTitle:localizedString(@"LIKE_VIDEO")
        message:localizedString(@"DID_WANT_LIKE_VIDEO")
        cancelButtonTitle:nil
        otherButtonTitles:@[localizedString(@"CONFIRM"), localizedString(@"CANCEL")]
        tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
          if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:localizedString(@"CONFIRM")]) {
            %orig;
          } 
        }];
    } else {
      %orig;
    }
  } else {
    %orig;
  }
}
%end

%hook IGFeedPhotoView
- (void)onDoubleTap:(id)tap {
  IGPost *post = ((IGFeedPhotoView *)[tap view]).parentCellView.post;
  NSDate *now = [NSDate date];
  BOOL needsAlert = [now timeIntervalSinceDate:[post.takenAt date]] > 86400.0f;

  if (!post.hasLiked && (alertMode == 2 || (alertMode == 1 && needsAlert))) {
    [UIAlertView showWithTitle:localizedString(@"LIKE_PHOTO")
    message:localizedString(@"DID_WANT_LIKE_PHOTO")
    cancelButtonTitle:nil
    otherButtonTitles:@[localizedString(@"CONFIRM"), localizedString(@"CANCEL")]
    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
      if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:localizedString(@"CONFIRM")]) {
        %orig;
      }
    }];
  } else {
    %orig;
  }
}
%end

// grid view

%hook IGFeedViewController
- (id)initWithFeedNetworkSource:(id)src feedLayout:(int)layout showsPullToRefresh:(BOOL)control {
  id thing = %orig;
  if (mainGrid && [src class] == [%c(IGMainFeedNetworkSource) class]) {
    [self setFeedLayout:2];
  }
  return thing;
}

// auto play video
- (void)startVideoForCellMovingOnScreen {
  if (enabled) {
    if (videoMode == 2 || (videoMode == 1 && !ringerMuted)) {
      return %orig;
    }
  } else {
    %orig;
  }
}
%end

// auto play audio

%hook IGFeedVideoPlayer
- (void)setReadyToPlay:(BOOL)ready {
  if (enabled) {
    if (audioMode == 2 || (audioMode == 1 && !ringerMuted)) {
      [self setAudioEnabled:YES];
    } else if (audioMode == 0) {
      [self setAudioEnabled:NO];
    }
  }
  %orig;
}
%end


// disable app rating

%hook Appirater
- (void)showRatingAlert {
  if (enabled && hideSponsored) {
    return;
  } else {
    return %orig;
  }
}
%end

// disable DM seen checks

%hook IGDirectThreadViewController
- (void)sendSeenTimestampForContent:(id)content {
  if (enabled && disableDMRead) {
    return;
  }
  %orig;
}
%end

%hook IGDirectedPost
- (void)performRead {
  if (enabled && disableDMRead) {
    return;
  }
  %orig;
}
- (BOOL)isRead {
  if (enabled && disableDMRead) {
    return false;
  }
  return %orig;
}
- (void)setIsRead:(BOOL)read {
  if (enabled && disableDMRead) {
    return %orig(NO);
  }
  return %orig;
}
%end

%hook IGDirectedPostRecipient
- (BOOL)hasRead {
  if (enabled && disableDMRead) {
    return false;
  }
  return %orig;
}
- (void)setHasRead:(BOOL)read {
  if (enabled && disableDMRead) {
    return %orig(NO);
  }
  return %orig;
}
%end

// follow status

%hook IGUser
- (void)onFriendStatusReceived:(NSDictionary *)status fromRequest:(id)req {
  if (enabled && followStatus) {
    UIViewController *currentController = [InstaHelper currentController];

    BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

    if (isProfileView) {
      IGUserDetailViewController *userView = (IGUserDetailViewController *) currentController;
      if (userView.headerView.statusLabel != nil) return %orig;
      CGRect containerFrame = userView.headerView.infoLabelContainerView.frame;
      CGRect addedContainer = CGRectMake(containerFrame.origin.x, containerFrame.origin.y + 5, 
        containerFrame.size.width, containerFrame.size.height);
      [userView.headerView.infoLabelContainerView setFrame:addedContainer];

      CGRect oldFrame = userView.headerView.followButton.frame;
      oldFrame.origin.y = oldFrame.size.height + oldFrame.origin.y + 5;

      UILabel *statusLabel = [[UILabel alloc] initWithFrame:oldFrame];
      statusLabel.numberOfLines = 1;
      statusLabel.backgroundColor = [UIColor colorWithRed:(246/255.0) green:(246/255.0) blue:(246/255.0) alpha:1];
      statusLabel.textColor = [UIColor colorWithRed:(99/255.0) green:(99/255.0) blue:(99/255.0) alpha:1];
      statusLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
      statusLabel.textAlignment = NSTextAlignmentCenter;
      statusLabel.layer.masksToBounds = YES;
      statusLabel.layer.cornerRadius = 8.0;
      CGPathRef shadowPath = CGPathCreateWithRect(statusLabel.bounds, NULL);
      statusLabel.layer.shadowPath = shadowPath;

      int followed_by = [[status objectForKey:@"followed_by"] intValue];
      int following = [[status objectForKey:@"following"] intValue];
      if (followed_by == 1 && following == 1) {
        statusLabel.text = localizedString(@"FOLLOW_EACH_OTHER");
      } else if (followed_by == 1) {
        statusLabel.text = localizedString(@"FOLLOWS_YOU");
      } else if (followed_by == 0) {
        statusLabel.text = localizedString(@"DOES_NOT_FOLLOW");
      }

      CGSize expectedSize = [statusLabel.text sizeWithAttributes:
        @{NSFontAttributeName: statusLabel.font}];
      oldFrame.size.width = expectedSize.width + 8;
      oldFrame.size.height = ceilf(expectedSize.height) + 4;
      statusLabel.frame = oldFrame;
      [userView.headerView setStatusLabel:statusLabel];
      [userView.headerView addSubview:statusLabel];
    }
  }

  %orig;
}

// fake following count

- (id)followingCount {
  UIViewController *currentController = [InstaHelper currentController];

  BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

  if (enabled && isProfileView && fakeFollowing) {
    return [NSNumber numberWithInt:fakeFollowing];
  }
  return %orig;
}

// fake follower count

- (id)followerCount {
  UIViewController *currentController = [InstaHelper currentController];

  BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

  if (enabled && isProfileView && fakeFollowers) {
    return [NSNumber numberWithInt:fakeFollowers];
  }
  return %orig;
}
%end

// open links in app

%hook IGUserDetailHeaderView 
- (void)coreTextView:(id)view didTapOnString:(id)str URL:(id)url {
  if (enabled && openInApp) {
    UIViewController *rootViewController = [InstaHelper rootViewController];
    [%c(IGURLHelper) openExternalURL:url controller:rootViewController modal:YES controls:YES completionHandler:nil];
  } else {
    %orig;
  }
}
%new
- (UILabel *)statusLabel {
  return objc_getAssociatedObject(self, @selector(statusLabel));
}

%new
- (void)setStatusLabel:(UILabel *)value {
  objc_setAssociatedObject(self, @selector(statusLabel), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%end

%hook IGWebViewController
- (void)viewDidLoad {
  %orig;
  if (![self isModal]) return;
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(closeController)];
  [self.navigationItem setLeftBarButtonItem:doneButton];
}

%new
- (void)closeController {
  [self dismissViewControllerAnimated:YES completion:nil];
}
%end

// save images and videos in direct messages

%hook IGDirectContentExpandableCell
- (void)layoutSubviews{
  if (enabled) {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(callShare:)];
    [longPress setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];
    [self.contentMenuLongPressRecognizer requireGestureRecognizerToFail:longPress];
    [longPress setMinimumPressDuration:1];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:longPress];
  }
  %orig;
}

%new
- (void)callShare:(UIGestureRecognizer *)longPress {
  if (longPress.state != UIGestureRecognizerStateBegan) return;

  if ([self.content isKindOfClass:[%c(IGDirectPhoto) class]]) {
    // provide action sheet in case image saving does not appear in share sheet
    UIActionSheet *actions = [[UIActionSheet alloc]
      initWithTitle:localizedString(@"ACTIONS")
      delegate:self
      cancelButtonTitle:localizedString(@"CANCEL")
      destructiveButtonTitle:nil
      otherButtonTitles:localizedString(@"SAVE_IMAGE"), localizedString(@"ZOOM"), nil];
    actions.tag = 182;

    [actions showInView:[UIApplication sharedApplication].keyWindow];
  } else if ([self.content isKindOfClass:[%c(IGDirectVideo) class]]) {
    // confirm that we want to save the video
    
    UIActionSheet *actions = [[UIActionSheet alloc]
      initWithTitle:localizedString(@"ACTIONS")
      delegate:self
      cancelButtonTitle:localizedString(@"CANCEL")
      destructiveButtonTitle:nil
      otherButtonTitles:localizedString(@"SAVE_VIDEO"), nil];
    actions.tag = 181;

    [actions showInView:[UIApplication sharedApplication].keyWindow];
  }
}

%new
- (void)actionSheet:(UIActionSheet *)popup didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if (popup.tag == 181) {
    if (buttonIndex != 0) return;
    IGVideo *media = ((IGDirectVideo *)self.content).video;
    NSString *versionURL = highestResImage(media.videoVersions);

    NSURL *vidURL = [NSURL URLWithString:versionURL];

    saveVideo(vidURL, nil);
  } else if (popup.tag == 182) {
    if (buttonIndex == 0) {
      IGPhoto *media = ((IGDirectPhoto *)self.content).photo;
      
      NSString *versionURL = highestResImage(media.imageVersions);
      NSURL *imgUrl = [NSURL URLWithString:versionURL];

      saveImage(imgUrl, nil);
    } else if (buttonIndex == 1) {
      NSMutableArray *photos = [[NSMutableArray alloc] init];
      InstaBetterPhoto *photo = [[InstaBetterPhoto alloc] init];

      [photos addObject:photo];

      NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];
      photosViewController.delegate = self;
      [[InstaHelper rootViewController] presentViewController:photosViewController animated:YES completion:nil];
      IGPhoto *media = ((IGDirectPhoto *)self.content).photo;
      
      NSString *versionURL = highestResImage(media.imageVersions);
      NSURL *imgUrl = [NSURL URLWithString:versionURL];
      dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      dispatch_async(queue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
        UIImage *img = [UIImage imageWithData:imgData];
        photo.image = img;
        dispatch_async(dispatch_get_main_queue(), ^{
          [photosViewController updateImageForPhoto:photo];
        });

      });
    }
  }
}
%end

// share sheet text

%hook IGCoreTextView
- (void)layoutSubviews {
  if (enabled) {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(callShare:)];
    [longPress setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];
    [longPress setMinimumPressDuration:1];
    [self addGestureRecognizer:longPress];
  }
  %orig;
}

%new
- (void)callShare:(UIGestureRecognizer *)longPress {
  if (longPress.state != UIGestureRecognizerStateBegan) return;
  UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
        initWithActivityItems:@[[self.styledString.attributedString string]]
        applicationActivities:nil];
  [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:nil];
}
%end

%hook IGFeedMediaView
- (void)layoutSubviews {
  if (enabled) {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [longPress setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];
    [longPress setMinimumPressDuration:1];
    [self addGestureRecognizer:longPress];
  }
  %orig;
}

%new
- (void)longPressed:(UIGestureRecognizer *)longPress {
  if (longPress.state != UIGestureRecognizerStateBegan) return;
  NSMutableArray *photos = [[NSMutableArray alloc] init];
  IGFeedItemPhotoCell *photoCell = (IGFeedItemPhotoCell *) self.superview.superview;
  InstaBetterPhoto *photo = [[InstaBetterPhoto alloc] init];
  UIImage *original = self.photoImageView.photoImageView.image;
  if (!loadHighRes && original) {
    photo.image = original;
  }

  if (photoCell.post.caption && photoCell.post.caption.text) {
    NSArray *items = [photoCell.post.caption.text componentsSeparatedByString:@" "];
    NSArray *summary = [items subarrayWithRange:NSMakeRange(0, ([items count] >= 8 ? 8 : [items count]))];
    NSMutableString *finalSummary = [[summary componentsJoinedByString:@" "] mutableCopy];
    if ([items count] > 8) {
      [finalSummary appendString:@"..."];
    }    
    if (finalSummary) {
      photo.attributedCaptionSummary = [[NSMutableAttributedString alloc] initWithString:finalSummary attributes:@{NSForegroundColorAttributeName: [UIColor grayColor]}];
    }
  }
  photo.attributedCaptionCredit = [[NSMutableAttributedString alloc] initWithString:photoCell.post.user.username attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];

  [photos addObject:photo];

  NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];
  photosViewController.delegate = self;

  if (loadHighRes || !original) {
    NSString *versionURL = highestResImage(photoCell.post.photo.imageVersions);
    NSURL *imgUrl = [NSURL URLWithString:versionURL];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
      NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
      UIImage *img = [UIImage imageWithData:imgData];
      photo.image = img;
      dispatch_async(dispatch_get_main_queue(), ^{
        [photosViewController updateImageForPhoto:photo];
      });

    });
  }

  [[InstaHelper rootViewController] presentViewController:photosViewController animated:YES completion:nil];
}

%new
- (CGFloat)photosViewController:(NYTPhotosViewController *)photosViewController maximumZoomScaleForPhoto:(id <NYTPhoto>)photo {
    return 5.0f;
}
%end

%hook IGProfilePictureImageView
- (void)didMoveToSuperview {
  %orig;
  if (enabled) {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [longPress setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];
    [longPress setMinimumPressDuration:1];
    [self addGestureRecognizer:longPress];
    [self setUserInteractionEnabled:YES];
  }
}

- (void)setUserInteractionEnabled:(BOOL)opt {
  if (enabled) {
    %orig(YES);
  } else {
    %orig;
  }
}

%new
- (void)longPressed:(UIGestureRecognizer *)longPress {
  if (longPress.state != UIGestureRecognizerStateBegan) return;
  NSMutableArray *photos = [[NSMutableArray alloc] init];
  InstaBetterPhoto *photo = [[InstaBetterPhoto alloc] init];

  if (self.user && self.user.username) {
    photo.attributedCaptionCredit = [[NSMutableAttributedString alloc] initWithString:self.user.username attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
  }

  [photos addObject:photo];

  NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];

  NSURL *imgUrl = self.user.profilePicURL;
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
    UIImage *img = [UIImage imageWithData:imgData];
    photo.image = img;
    dispatch_async(dispatch_get_main_queue(), ^{
      [photosViewController updateImageForPhoto:photo];
    });
  });

  [[InstaHelper rootViewController] presentViewController:photosViewController animated:YES completion:nil];
}
%end

// action sheet manager

%hook IGActionSheet
- (void)show {
  if (enabled) {
    UIViewController *currentController = [InstaHelper currentController];

    BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];
    BOOL isWebView = [currentController isKindOfClass:[%c(IGWebViewController) class]];
    IGUserDetailViewController *userView = (IGUserDetailViewController *) currentController;
    // BOOL isFollowing = NO;
    // if (isProfileView) {
    //   int status = userView.user.followStatus;
    //   if (status == 3) {
    //     isFollowing = YES;
    //   }
    // }
    // if (isProfileView && (([self.buttons count] == 6 && isFollowing) || ([self.buttons count] == 5 && !isFollowing)) && !self.titleLabel.text) {
    if (isProfileView && !cachedItem && !self.titleLabel.text) {
        IGUser *current = [InstaHelper currentUser];
        if ([current.username isEqualToString:userView.user.username]) return %orig;
        if ([muted containsObject:userView.user.username]) {
            [self addButtonWithTitle:instaUnmute style:0];
        } else {
            [self addButtonWithTitle:instaMute style:0];
        }
    } else if (!self.titleLabel.text && !isWebView) {
      if (saveActions && saveMode == 1) { 
        [self addButtonWithTitle:instaSave style:0];
        IGUser *current = [InstaHelper currentUser];
        if (cachedItem && cachedItem.user == current) {
          cachedItem = nil;
        } else {
          [self addButtonWithTitle:localizedString(@"SHARE") style:0]; 
        }
      }    
    }
  }
  %orig;
}
- (void)hideAndReset {
  cachedItem = nil;
  %orig;
}
%end

// mute users from activity
%hook IGNewsTableViewController
+ (id)storiesWithDictionaries:(id)arr {
  if (enabled && muteActivity) {
    NSMutableArray *finalArray = [arr mutableCopy];
    NSUInteger index = 0;
    for (NSDictionary* dict in arr) {
      NSArray *links = [dict valueForKeyPath:@"args.links"];
      if ([links count] == 1) {
        NSArray* words = [[dict valueForKeyPath:@"args.text"] componentsSeparatedByString:@" "];
        if ([muted containsObject:[words objectAtIndex:0]]) {
          if ([muted count] >= (index - 1)) {
            [finalArray removeObjectAtIndex:index];
          }
        }
      }
      index++;
    }
    arr = [finalArray copy];
  }
  return %orig;
}
%end


%hook IGUserDetailViewController
// manage multiple users
- (void)viewDidLoad {
  %orig;
  if (!(enabled && accountSwitcher)) return;
  IGAuthHelper *authHelper = [%c(IGAuthHelper) sharedAuthHelper];
  if (self.user != [authHelper currentUser]) return;
  UIBarButtonItem *userButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"tabsPeopleIcon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(openSwitcher)];
  self.navigationItem.leftBarButtonItem = userButton;
}

- (void)switchUsersController:(id)contrl tableViewDidSelectRowWithUser:(id)user {
  %orig;
  [self animateSwitchUsersTableView];
  AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
  [igDelegate application:nil didFinishLaunchingWithOptions:nil];
}

// mute users
- (void)actionSheetDismissedWithButtonTitled:(NSString *)title {
  if (enabled) {
    if ([title isEqualToString:instaMute]) {
      NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
      [muted addObject:self.user.username];
      [prefs setValue:muted forKey:@"muted_users"];
      [prefs writeToFile:prefsLoc atomically:NO];
    } else if ([title isEqualToString:instaUnmute]) {
      NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
      [muted removeObject:self.user.username];
      [prefs setValue:muted forKey:@"muted_users"];
      [prefs writeToFile:prefsLoc atomically:NO];
    } else {
      %orig;
    }
  } else {
    %orig;
  }
}

%new
- (void)openSwitcher {
  [self onNeedsFullReload];
  [self animateSwitchUsersTableView];
}
%end

%hook IGMainFeedViewController
- (BOOL)shouldHideFeedItem:(IGFeedItem *)item {
  if (enabled) {
    BOOL contains = [muted containsObject:item.user.username];
    if ((contains && muteMode == 0) || (!contains && muteMode == 1)) {
      return YES;
    } else {
      return %orig;
    }
  } else {
    return %orig;
  }
}

- (void)viewDidLoad {
  %orig;
  if (!(enabled && layoutSwitcher)) return;
  if (!gridItem || !listItem) {
    gridItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"feedtoggle-grid-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(changeView)];
    listItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"feedtoggle-list-icon.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(changeView)];
  }
  if (self.feedLayout == 1) {
    self.navigationItem.leftBarButtonItem = gridItem;
  } else if (self.feedLayout == 2) {
    self.navigationItem.leftBarButtonItem = listItem;
  }
}

%new
- (void)changeView {
  if (self.feedLayout == 2) {
    [self setFeedLayout:1];
    [self.navigationItem setLeftBarButtonItem:gridItem animated:YES];
  } else if (self.feedLayout == 1) {
    [self setFeedLayout:2];
    [self.navigationItem setLeftBarButtonItem:listItem animated:YES];
  }
}
%end

%hook IGFeedItemTextCell
- (IGStyledString *)styledStringForLikesWithFeedItem:(IGFeedItem *)item {
    IGStyledString *styled = %orig;
    if (enabled && showPercents) {
      int likeCount = [[likesDict objectForKey:[item getMediaId]] intValue];
      if (likeCount && likeCount == item.likeCount) {
        return styled;
      } else {
        if (item.user.followerCount) {
          [likesDict setObject:[NSNumber numberWithInt:item.likeCount] forKey:[item getMediaId]];
            int followers = [item.user.followerCount intValue];
            float percent = ((float)item.likeCount / (float)followers) * 100.0;
            NSString *display = [NSString stringWithFormat:@" (%.01f%%)", percent];
            NSMutableAttributedString *original = [[NSMutableAttributedString alloc] initWithAttributedString:[styled attributedString]];
            NSMutableDictionary *attributes = [[original attributesAtIndex:0 effectiveRange:NULL] mutableCopy];
            UIColor *col = nil;
            if (percent <= 20.0) {
              col = [UIColor redColor];
            } else if (percent > 20.0 && percent <= 45.0) {
              col = [UIColor orangeColor];
            } else if (percent > 45.0 && percent <= 72.0) {
              col = [UIColor yellowColor];
            } else {
              col = [UIColor greenColor];
            }
            [attributes setObject:col forKey:NSForegroundColorAttributeName];
            NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:display attributes:attributes];
            [original appendAttributedString:formatted];
            [styled setAttributedString:original];
            return styled;
          }
      }
    }
    return styled;
}
%end

%hook IGFeedItem
- (id)initWithDictionary:(id)data {
  id item = %orig;
  if (enabled && showPercents) {
    UIViewController *currentController = [InstaHelper currentController];

    BOOL isPostsView = [currentController isKindOfClass:[%c(IGPostsFeedViewController) class]];
    BOOL isMainView = [currentController isKindOfClass:[%c(IGMainFeedViewController) class]];
    if (isPostsView || isMainView) {
      dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      dispatch_async(queue, ^{
        [self.user fetchAdditionalUserDataWithCompletion:nil];
      });
    }
  }
  return item;
}
%end

%hook AppDelegate
- (void)applicationDidEnterBackground:(id)application {
  if (enabled && showPercents) {
    [likesDict removeAllObjects];
  }
  %orig;
}
%end

// save media
%hook IGFeedItemActionCell
- (void)onMoreButtonPressed:(id)sender {
  cachedItem = self.feedItem;
  %orig;
}

- (void)layoutSubviews {
  %orig;

  if (!(enabled && saveActions && saveMode == 0)) return;
  if (self.saveButton) return;

  CGRect firstFrame;
  CGRect compareFrame;
  UIButton *base;
  
  if (self.sendButton) {
    base = self.sendButton;
    firstFrame = self.commentButton.frame;
    compareFrame = self.sendButton.frame;
  } else {
    base = self.likeButton;
    firstFrame = self.likeButton.frame;
    compareFrame = self.commentButton.frame;
  }

  float distance = (compareFrame.origin.x - firstFrame.origin.x);

  NSData *archivedData = [NSKeyedArchiver archivedDataWithRootObject:base];
     
  UIButton *saveButton = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
  saveButton.frame = CGRectMake(compareFrame.origin.x + distance, compareFrame.origin.y, compareFrame.size.width, compareFrame.size.height);
  UIImage *saveImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"download@3x" ofType:@"png"]];
  [saveButton addTarget:self action:@selector(saveItem:) forControlEvents:UIControlEventTouchUpInside];
  [saveButton setImage:saveImage forState:UIControlStateNormal];
  [self addSubview:saveButton];
  [self setSaveButton:saveButton];


  // don't add share button to own posts
  IGUser *current = [InstaHelper currentUser];
  if ([current.username isEqualToString:self.feedItem.user.username]) return;

  UIButton *shareButton = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
  shareButton.frame = CGRectMake(saveButton.frame.origin.x + distance, compareFrame.origin.y, compareFrame.size.width, compareFrame.size.height);
  UIImage *shareImage = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"share@3x" ofType:@"png"]];
  [shareButton addTarget:self action:@selector(shareItem:) forControlEvents:UIControlEventTouchUpInside];
  [shareButton setImage:shareImage forState:UIControlStateNormal];
  [self addSubview:shareButton];
}

%new
- (void)saveItem:(id)sender {
  if (!saveConfirm) {
    return [self saveNow];
  }
  [UIAlertView showWithTitle:localizedString(@"SAVE_CONTENT")
  message:localizedString(@"DID_WANT_SAVE_CONTENT")
  cancelButtonTitle:nil
  otherButtonTitles:@[localizedString(@"CONFIRM"), localizedString(@"CANCEL")]
  tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:localizedString(@"CONFIRM")]) {
      [self saveNow];
    }
  }];
}

%new
- (void)saveNow {
  IGFeedItem *item = self.feedItem;
  saveMedia(item);
}

%new
- (void)shareItem:(id)sender {
  IGFeedItem *item = self.feedItem;
  NSURL *link = [NSURL URLWithString:[item permalink]];
  UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
    initWithActivityItems:@[link]
    applicationActivities:nil];
  [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:nil];
}

%new
- (UIButton *)saveButton {
  return objc_getAssociatedObject(self, @selector(saveButton));
}

%new
- (void)setSaveButton:(UIButton *)value {
  objc_setAssociatedObject(self, @selector(saveButton), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)actionSheetDismissedWithButtonTitled:(NSString *)title {
  if (enabled) {
    if ([title isEqualToString:instaSave]) {
      IGFeedItem *item = self.feedItem;
      saveMedia(item);
    } else if ([title isEqualToString:localizedString(@"SHARE")] && saveActions && saveMode == 1) {
      IGFeedItem *item = self.feedItem;
      if (item.user == [InstaHelper currentUser]) return %orig;
      NSURL *link = [NSURL URLWithString:[item permalink]];
      UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
        initWithActivityItems:@[link]
        applicationActivities:nil];
      [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:nil];
    } else {
      %orig;
    }
  } else {
    %orig;
  }
}
%end

// custom locations
%hook IGLocationPickerViewController
- (void)viewDidLoad {
  %orig;
  if (!(enabled && customLocations)) return;
  UIBarButtonItem *userButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location-pin-inactive.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(selectCustom)];
  [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:self.navigationItem.leftBarButtonItem, userButton, nil]];
}

%new
- (void)selectCustom {
  LocationSelectorViewController *sel = [[LocationSelectorViewController alloc] init];
  UINavigationController *selNav = [[UINavigationController alloc] initWithRootViewController:sel];
  selNav.modalPresentationStyle = UIModalPresentationFullScreen;
  sel.delegate = self;

  [self presentViewController:selNav animated:YES completion:nil];
}

%new
- (void)didSelectLocation:(CLLocationCoordinate2D)location {
  double longitude = location.longitude;
  double latitude = location.latitude;
  CLLocation *rawLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
  IGLocation *loc = [[%c(IGLocation) alloc] init];
  [loc setLocationCoord:rawLocation];

  [self setTempLocation:loc];

  UIAlertView * alert = [[UIAlertView alloc] initWithTitle:localizedString(@"LOCATION_DISPLAY") message:localizedString(@"LOCATION_DISPLAY_MSG") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
  alert.alertViewStyle = UIAlertViewStylePlainTextInput;
  alert.tag = 107;
  [alert show];
}

%new
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  NSString *text = [[alertView textFieldAtIndex:0] text];
  if (alertView.tag == 107) {
    if (buttonIndex == 0) return;
    [self.tempLocation setName:text];
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:localizedString(@"LOCATION_ADDRESS") message:localizedString(@"LOCATION_ADDRESS_MSG") delegate:self cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 7;
    [alert show];
  } else if (alertView.tag == 7) {
    [self.tempLocation setStreetAddress:text];
    [self.tempLocation setExternalSource:@"facebook_places"];
    [self.tempLocation setFacebookPlacesID:@"001358180265847"];

    [self locationPickerViewController:self didFinish:TRUE withLocation:self.tempLocation];
  }
}

%new
- (IGLocation *)tempLocation {
  return objc_getAssociatedObject(self, @selector(tempLocation));
}

%new
- (void)setTempLocation:(IGLocation *)value {
  objc_setAssociatedObject(self, @selector(tempLocation), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%end

// hide sponsored posts

%hook IGFeedItemTimelineLayoutAttributes
- (BOOL)sponsoredContext {
  if (enabled && hideSponsored) {
    return false;
  } else {
    return %orig;
  }
}
%end

%hook IGFeedItemHeader
- (void)layoutSubviews {
  %orig;
  if (enabled && enableTimestamps) {
    if (alwaysTimestamp) {
      showTimestamp(self, false);
      return;
    }
    origPosition = self.timestampLabel.frame.origin.x;
    [self.timestampLabel setUserInteractionEnabled:YES];

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTimestamp)];
    [self.timestampLabel addGestureRecognizer:singleTap];
  }
}

%new
- (void)showTimestamp {
  if (self.timestampLabel.frame.origin.x == origPosition) {
    showTimestamp(self, true);
  }
}
%end

%hook IGFeedItemActionCell   
- (BOOL)sponsoredPostAllowed {    
  if (enabled && hideSponsored) {    
    return false;    
  } else {   
    return %orig;    
  }    
}    
%end

%hook IGSponsoredPostInfo
- (BOOL)showIcon {
  if (enabled && hideSponsored) {
    return false;
  } else {
    return %orig;
  }
}
- (BOOL)hideCommentButton {
  if (enabled && hideSponsored) {
    return true;
  } else {
    return %orig;
  }
}
- (BOOL)isHoldout {
  if (enabled && hideSponsored) {
    return true;
  } else {
    return %orig;
  }
}
- (BOOL)hideComments {
  if (enabled && hideSponsored) {
    return true;
  } else {
    return %orig;
  }
}
%end

%hook IGAccountSettingsViewController
- (id)settingSectionRows {
  NSArray *thing = %orig;
  if ([thing count] == 4) {
    return [NSArray arrayWithObjects:@0, @1, @2, @3, @4, nil];
  } else if ([thing count] == 5) {
    return [NSArray arrayWithObjects:@0, @1, @2, @3, @4, @5, nil];
  }
  return nil;
}

- (int)tableView:(id)tableView numberOfRowsInSection:(int)sections {
  if (sections == 2) {
    return [[self settingSectionRows] count];
  }
  return %orig;
}

- (id)tableView:(id)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  IGGroupedTableViewCell* cell = %orig;
  int count = [[self settingSectionRows] count];
  if (indexPath.section == 2 && ((count == 5 && indexPath.row == 4) || (count == 6 && indexPath.row == 5))) {
    cell.textLabel.text = localizedString(@"INSTABETTER_SETTINGS");
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  }
  return cell;
}

- (void)tableView:(id)tableView didSelectSettingsRow:(int)index {
  int count = [[self settingSectionRows] count];
  if ((count == 5 && index == 4) || (count == 6 && index == 5)) {
    InstaBetterPrefsController *settings = [[InstaBetterPrefsController alloc] init];
    UIViewController *rootController = (UIViewController *) settings;

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootController];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeSettings)];
    rootController.navigationItem.rightBarButtonItem = doneButton;
    if (rootController) {
      [[InstaHelper rootViewController] presentViewController:navigationController animated:YES completion:nil];
    }
    return;
  }
  %orig;
}

%new
- (void)closeSettings {
  [[InstaHelper rootViewController] dismissViewControllerAnimated:YES completion:nil];
}
%end

%end

%group sbHooks

%hook BBBulletin
- (BBSound *)sound {
  if (![self.section isEqualToString:@"com.burbn.instagram"]) return %orig;
  if (!(enabled && notificationsEnabled)) return nil;
  NSString *audioFile;
  NSString *type = [self.context valueForKeyPath:@"remoteNotification.aps.category"];

  if ([type isEqualToString:@"like"]) {
    audioFile = notificationsLike;
  } else if ([type isEqualToString:@"comment"]) {
    audioFile = notificationsComment;
  } else if ([type isEqualToString:@"new_follower"]) {
    audioFile = notificationsNewFollower;
  } else if ([type isEqualToString:@"private_user_follow_request"]) {
    audioFile = notificationsFollowRequest;
  } else if ([type isEqualToString:@"follow_request_approved"]) {
    audioFile = notificationsRequestApproved;
  } else if ([type isEqualToString:@"usertag"]) {
    audioFile = notificationsUsertag;
  } else if ([type hasPrefix:@"direct"]) {
    //direct_v2_media_share
    //direct_v2_like
    //direct_v2_text
    //direct_v2_media
    audioFile = notificationsDirect;
  }

  if (!audioFile || [audioFile isEqualToString:@"Default"]) {
    return [%c(BBSound) alertSoundWithSystemSoundID:1015];
  } else if ([audioFile isEqualToString:@"(none)"]) {
    return nil;
  }

  return [%c(BBSound) alertSoundWithSystemSoundPath:[NSString stringWithFormat:@"/System/Library/Audio/UISounds/%@", audioFile]];
}
%end

%end

static void handlePrefsChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  loadPrefs();
}

static void setRingerState(uint64_t state) {
  if (state == 0) {
    ringerMuted = YES;
  } else if (state == 1) {
    ringerMuted = NO;
  } else {
    ringerMuted = YES;
  }
}

static void setupRingerCheck() {
  notify_register_dispatch("com.apple.springboard.ringerstate",
    &ringerState,
    dispatch_get_main_queue(), ^(int t) {
      uint64_t state;
      notify_get_state(ringerState, &state);
      setRingerState(state);
    });

  notify_post("com.apple.springboard.ringerstate");
}

%ctor {

  @autoreleasepool {
    NSString *curBundle = [NSBundle mainBundle].bundleIdentifier;

    loadPrefs();

    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), 
      NULL,
      &handlePrefsChange,
      (CFStringRef)@"com.jake0oo0.instabetter/prefsChange",
      NULL, 
      CFNotificationSuspensionBehaviorCoalesce);

    if ([curBundle isEqualToString:@"com.apple.springboard"]) {
      %init(sbHooks);
    } else {
      [bundle load];
      setupRingerCheck();

      %init(instaHooks);
    }
  }
}
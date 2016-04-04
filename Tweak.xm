#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
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
// static NSMutableDictionary *likesDict = [[NSMutableDictionary alloc] init];

static BOOL enabled = YES;
// static BOOL showPercents = YES;
static BOOL hideSponsored = YES;
static int muteMode = 0;
static BOOL muteActivity = YES;
static BOOL muteFeed = YES;
static BOOL saveActions = YES;
static NSString *customAlbum = @"Instagram";
static BOOL followStatus = YES;
static BOOL customLocations = YES;
static BOOL openInApp = YES;
static BOOL parseURLs = YES;
static BOOL disableDMRead = NO;
static BOOL loadHighRes = NO;
static BOOL mainGrid = NO;
static BOOL returnKey = NO;
static BOOL layoutSwitcher = YES;
static int audioMode = 1;
static int videoMode = 1;
static int alertMode = 1;
static BOOL showRepost = NO;
static int saveMode = 1;
static int shareMode = 1;
static int saveConfirm = YES;
static int fakeFollowers = nil;
static int fakeFollowing = nil;
static BOOL fakeVerified = NO;
static BOOL enableTimestamps = YES;
static int timestampFormat = 0;
static BOOL alwaysTimestamp = NO;
static BOOL useSafariController = YES;
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

NSString *cachedCaption;

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
      // showPercents = [prefs objectForKey:@"show_percents"] ? [[prefs objectForKey:@"show_percents"] boolValue] : YES;
      customLocations = [prefs objectForKey:@"custom_locations"] ? [[prefs objectForKey:@"custom_locations"] boolValue] : YES;
      returnKey = [prefs objectForKey:@"return_key"] ? [[prefs objectForKey:@"return_key"] boolValue] : NO;

      disableDMRead = [prefs objectForKey:@"disable_read_notification"] ? [[prefs objectForKey:@"disable_read_notification"] boolValue] : NO;
      loadHighRes = [prefs objectForKey:@"zoom_hi_res"] ? [[prefs objectForKey:@"zoom_hi_res"] boolValue] : NO;

      openInApp = [prefs objectForKey:@"app_browser"] ? [[prefs objectForKey:@"app_browser"] boolValue] : YES;
      parseURLs = [prefs objectForKey:@"parse_urls"] ? [[prefs objectForKey:@"parse_urls"] boolValue] : YES;
      useSafariController = [prefs objectForKey:@"safari_controller"] ? [[prefs objectForKey:@"safari_controller"] boolValue] : YES;

      mainGrid = [prefs objectForKey:@"main_grid"] ? [[prefs objectForKey:@"main_grid"] boolValue] : NO;
      layoutSwitcher = [prefs objectForKey:@"layout_switcher"] ? [[prefs objectForKey:@"layout_switcher"] boolValue] : YES;

      muteMode = [prefs objectForKey:@"mute_mode"] ? [[prefs objectForKey:@"mute_mode"] intValue] : 0;
      muteActivity = [prefs objectForKey:@"mute_activity"] ? [[prefs objectForKey:@"mute_activity"] boolValue] : YES;
      muteFeed = [prefs objectForKey:@"mute_feed"] ? [[prefs objectForKey:@"mute_feed"] boolValue] : YES;
      muted = [prefs objectForKey:@"muted_users"] ? [prefs objectForKey:@"muted_users"] : [[NSMutableArray alloc] init];

      alertMode = [prefs objectForKey:@"alert_mode"] ? [[prefs objectForKey:@"alert_mode"] intValue] : 1;

      saveActions = [prefs objectForKey:@"save_actions"] ? [[prefs objectForKey:@"save_actions"] boolValue] : YES;
      saveMode = [prefs objectForKey:@"save_mode"] ? [[prefs objectForKey:@"save_mode"] intValue] : 1;
      shareMode = [prefs objectForKey:@"share_mode"] ? [[prefs objectForKey:@"share_mode"] intValue] : 1;
      customAlbum = [prefs objectForKey:@"custom_album"] ? [prefs objectForKey:@"custom_album"] : @"Instagram";
      if (customAlbum && [customAlbum isEqualToString:@""]) {
        // check for blank album
        customAlbum = @"Instagram";
      }
      saveConfirm = [prefs objectForKey:@"save_confirm"] ? [[prefs objectForKey:@"save_confirm"] boolValue] : YES;
      showRepost = [prefs objectForKey:@"show_repost"] ? [[prefs objectForKey:@"show_repost"] boolValue] : NO;

      // video and audio
      audioMode = [prefs objectForKey:@"audio_mode"] ? [[prefs objectForKey:@"audio_mode"] intValue] : 1;
      videoMode = [prefs objectForKey:@"video_mode"] ? [[prefs objectForKey:@"video_mode"] intValue] : 1;

      // spoofing
      fakeFollowers = [prefs objectForKey:@"fake_follower_count"] ? [[prefs objectForKey:@"fake_follower_count"] intValue] : nil;
      fakeFollowing = [prefs objectForKey:@"fake_following_count"] ? [[prefs objectForKey:@"fake_following_count"] intValue] : nil;
      fakeVerified = [prefs objectForKey:@"fake_verified"] ? [[prefs objectForKey:@"fake_verified"] boolValue] : NO;

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

static NSString* highestResImage(NSDictionary *versions) {
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

static void saveMedia(NSURL *url) {
  if (enabled && saveActions) {
    UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *status = [MBProgressHUD showHUDAddedTo:appWindow animated:YES];
    status.labelText = localizedString(@"SAVING");
    UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"37x-Checkmark@2x" ofType:@"png"]]];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
      if ([InstaHelper isRemoteImage:url]) {
        [InstaHelper saveRemoteImage:url album:customAlbum completion:^(NSError *err) {
          dispatch_async(dispatch_get_main_queue(), ^{
            status.customView = img;
            status.mode = MBProgressHUDModeCustomView;
            status.labelText = localizedString(@"SAVED");

            [status hide:YES afterDelay:1.0];
          });
        }];
      } else {
        [InstaHelper saveRemoteVideo:url album:customAlbum completion:^(NSError *err) {
          dispatch_async(dispatch_get_main_queue(), ^{
            status.customView = img;
            status.mode = MBProgressHUDModeCustomView;
            status.labelText = localizedString(@"SAVED");

            [status hide:YES afterDelay:1.0];
          });
        }];
      }
    });
  }
}

static void savePhoto(IGPhoto *photo) {
  NSString *versionURL = highestResImage(photo.imageVersions);
  NSURL *imgURL = [NSURL URLWithString:versionURL];
  saveMedia(imgURL);
}

static void saveVideo(IGVideo *video) {
  NSString *versionURL = highestResImage(video.videoVersions);
  NSURL *vidURL = [NSURL URLWithString:versionURL];
  saveMedia(vidURL);
}

static void saveFeedItem(IGPost *post) {
  if (post.mediaType == 1) {
    savePhoto(post.photo);
  } else if (post.mediaType == 2) {
    saveVideo(post.video);
  }
}


// show timestamps on IGFeedItems
// header - IGFeedItemheader for relevant IGFeedItem
// animated - whether or not displaying the timestamp should be animated
static void showTimestamp(IGFeedItemHeader *header, BOOL animated) {
  IGFeedItem *feedItem = nil;
  BOOL responds = [header respondsToSelector:@selector(viewModel)];
  if (responds) {
    IGFeedItemHeaderViewModel *model = [header viewModel];
    feedItem = [model feedItem];
  } else {
    feedItem = [header feedItem];
  }


  NSDate *takenAt = [InstaHelper takenAt:feedItem];

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

static BOOL openExternalURL(NSURL* url) {
  if (enabled && openInApp) {
    if ([%c(SFSafariViewController) class] != nil && useSafariController) {
      NSString *scheme = [[url scheme] lowercaseString];

      if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"https"]) {
        SFSafariViewController *sfvc = [[%c(SFSafariViewController) alloc] initWithURL:url];
        [[InstaHelper rootViewController] presentViewController:(UIViewController*)sfvc animated:YES completion:nil];
      } else {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
          [[UIApplication sharedApplication] openURL:url];
        } else {
          UIAlertView * alert = [[UIAlertView alloc] initWithTitle:localizedString(@"FAILED_OPEN") 
            message:localizedString(@"FAILED_OPEN_MSG") delegate:nil cancelButtonTitle:@"Okay" 
            otherButtonTitles:nil];
          [alert show];
        }
      }
    } else {
      UIViewController *rootViewController = [InstaHelper rootViewController];
      [%c(IGURLHelper) openExternalURL:url controller:rootViewController modal:YES controls:YES completionHandler:nil];
    }
    return true;
  }
  return false;
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

%hook IGUnreadBubbleView
-(void)setUnreadCount:(int)arg1 {
  if (!enabled) return;
  self.label.text = [NSString stringWithFormat:@"%d", arg1];
}
%end


// parse URLs in styled strings
%hook IGCommentModel
- (id)buildStyledStringWithNewline:(char)arg1 width:(float)arg2 numberOfLines:(int)arg3 truncationToken:(id)arg4 {
  if (enabled && parseURLs) {
    IGStyledString *styled = (IGStyledString*)%orig;
    NSString *string = styled.attributedString.string;
    NSError *error = nil;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    NSMutableAttributedString *attr = [styled.attributedString mutableCopy];
    [detector enumerateMatchesInString:string
     options:0
     range:NSMakeRange(0, string.length)
     usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
      NSURL *url = result.URL;
      if (result.resultType == NSTextCheckingTypeLink && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
        NSRange range = NSMakeRange(result.range.location, result.range.length);
        [attr addAttribute:@"URL" value:url range:range];
        [attr addAttribute:NSLinkAttributeName value:url range:range];
        [attr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:0.0705882 green:0.337255 blue:0.533333 alpha:1.0] range:range]; 

      }         
    }];
    styled.attributedString = attr;
  }
  return %orig;
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
// instagram 7.14+, backwards compatible (untested)
- (BOOL)textViewDidBeginEditing:(UITextView *)textView {
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

%hook IGFeedItemPhotoCell 
- (void)feedPhotoDidDoubleTapToLike:(id)tap {
  if (!enabled) return %orig;
  IGPost *post = [self post];
  NSDate *now = [NSDate date];

  BOOL needsAlert = [now timeIntervalSinceDate:[InstaHelper takenAt:post]] > 86400.0f;

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

%hook IGFeedItemVideoCell 
- (void)feedItemVideoViewDidDoubleTap:(id)tap {
  if (!enabled) return %orig;
  IGPost *post = [self post];
  NSDate *now = [NSDate date];

  BOOL needsAlert = [now timeIntervalSinceDate:[InstaHelper takenAt:post]] > 86400.0f;

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
}
%end

// replacement for auto starting videos in ig >= 7.14
%hook IGFeedVideoCellManager
- (BOOL)startVideoForCellIfApplicable:(id)arg1 {
  if (enabled && (videoMode == 2 || (videoMode == 1 && !ringerMuted))) {
    return %orig;
  } else {
    return NO;
  }
}
%end

%hook IGShareViewController
-(void)viewDidLoad {
  %log;
  if (cachedCaption) {
    self.mediaMetadata.caption = cachedCaption;
    self.captionCell.text = cachedCaption;
    cachedCaption = nil;
  }

  %orig;
}
%end

%hook IGFeedViewController_DEPRECATED
- (id)initWithFeedNetworkSource:(id)src feedLayout:(int)layout showsPullToRefresh:(BOOL)control {
  id thing = %orig;
  if (enabled && mainGrid && [src class] == [%c(IGMainFeedNetworkSource) class]) {
    [self setFeedLayout:2];
  }
  return thing;
}

- (void)feedItemActionCellDidTapMoreButton:(IGFeedItemActionCell*)cell {
  cachedItem = cell.feedItem;
  %orig;
}


// instagram 7.19
- (void)feedItemHeaderDidTapOnMoreButton:(IGFeedItemHeader*)header {
  cachedItem = header.viewModel.feedItem;
  %orig;
}

- (void)actionSheetDismissedWithButtonTitled:(NSString*)title {
  if (enabled) {
    IGFeedItem *item = cachedItem;
    if ([title isEqualToString:instaSave]) {
      return saveFeedItem(item);
    } else if ([title isEqualToString:localizedString(@"SHARE")] && saveActions && saveMode == 1) {
      if (item.user == [InstaHelper currentUser]) return %orig;
      UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
      MBProgressHUD *status = [MBProgressHUD showHUDAddedTo:appWindow animated:YES];
      status.labelText = localizedString(@"PREPARING");
      // share Instagram link, direct link, actual photo
      if (shareMode == 0 || shareMode == 1) {
        NSURL *link = nil;
        if (shareMode == 0) {
          link = [NSURL URLWithString:[item permalink]];
        } else if (shareMode == 1) {
          if (item.mediaType == 1) {
            link = [NSURL URLWithString:highestResImage(item.photo.imageVersions)];
          } else if (item.mediaType == 2) {
            link = [NSURL URLWithString:highestResImage(item.video.videoVersions)];
          }
          
        }
        status.labelText = localizedString(@"DISPLAYING");

        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
          initWithActivityItems:@[link]
          applicationActivities:nil];
        return [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:^{
          status.labelText = localizedString(@"DONE");
          [status hide:YES afterDelay:0.5];
        }];
      } else if (shareMode == 2) {
         
        NSURL *perma = [NSURL URLWithString:[item permalink]];
        if (item.mediaType == 1) {
          status.labelText = localizedString(@"DOWNLOADING_IMAGE");
          NSURL *highest = [NSURL URLWithString:highestResImage(item.photo.imageVersions)];
          [InstaHelper downloadRemoteFile:highest completion:^(NSData *data, NSError *err) {
            if (err || !data) {
              status.labelText = localizedString(@"FAILED_TO_LOAD_IMAGE");
              return [status hide:YES afterDelay:1.0];
            }
            UIImage *img = [UIImage imageWithData:data];
            status.labelText = localizedString(@"DISPLAYING");
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
              initWithActivityItems:@[img, perma]
              applicationActivities:nil];
            return [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:^{
              status.labelText = localizedString(@"DONE");
              [status hide:YES afterDelay:0.5];
            }];
          }];
          return;
          // UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
          //   initWithActivityItems:@[link]
          //   applicationActivities:nil];
        } else if (item.mediaType == 2) {

          NSURL *highest = [NSURL URLWithString:highestResImage(item.video.videoVersions)];

          NSFileManager *fsmanager = [NSFileManager defaultManager];
          NSURL *videoDocs = [[fsmanager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
          NSURL *saveUrl = [videoDocs URLByAppendingPathComponent:[highest lastPathComponent]];
          status.labelText = localizedString(@"DOWNLOADING_VIDEO");
          [InstaHelper saveRemoteVideo:highest album:customAlbum completion:^(NSError *err) {
            if (err) {
              status.labelText = localizedString(@"FAILED_TO_LOAD_IMAGE");
              return [status hide:YES afterDelay:1.0];
            }

            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
              initWithActivityItems:@[[NSURL fileURLWithPath:[saveUrl absoluteString]]]
              applicationActivities:nil];
            return [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:^{
                status.labelText = localizedString(@"DONE");
                [status hide:YES afterDelay:0.5];
              }];

          }];
        }
      }

      // return [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:nil];
    } else if (item && [title isEqualToString:localizedString(@"REPOST")]) {
      if (item.user == [InstaHelper currentUser]) return %orig;
      IGRootViewController *root = [InstaHelper rootViewController];
      NSArray *controllers = [root childViewControllers];
      IGMainAppViewController *main = controllers[0];
      IGMediaMetadata *meta = [[%c(IGMediaMetadata) alloc] init];
      meta.caption = item.caption ? item.caption.text : nil;
      cachedCaption = meta.caption;
      UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
      MBProgressHUD *status = [MBProgressHUD showHUDAddedTo:appWindow animated:YES];
      status.labelText = localizedString(@"PREPARING");

      if (item.mediaType == 1) {
        NSString *versionURL = highestResImage(item.photo.imageVersions);
        NSURL *imgUrl = [NSURL URLWithString:versionURL];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        status.labelText = localizedString(@"LOADING_IMAGE");
        dispatch_async(queue, ^{
          NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
          UIImage *img = [UIImage imageWithData:imgData];
          meta.snapshot = img;
          dispatch_async(dispatch_get_main_queue(), ^{
            status.labelText = localizedString(@"LOADING_VIEWS");
            [main presentCameraWithMetadata:meta mode:1];

            IGCameraNavigationController *camera = [main cameraController];

            IGEditorViewController *editor = [[%c(IGEditorViewController) alloc] initForImageFromCameraWithMediaMetadata:meta];


            [editor setImage:img cropRect:CGRectMake(0, 0, img.size.width, img.size.height)];
            editor.readyToProceed = YES;

            [camera pushViewController:editor animated:YES];

            [status hide:YES afterDelay:1.0];
          });

        });
      } else if (item.mediaType == 2) {
        NSString *versionURL = highestResImage(item.video.videoVersions);
        NSURL *url = [NSURL URLWithString:versionURL];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        status.labelText = localizedString(@"LOADING_VIDEO");


        dispatch_async(queue, ^{
          CGSize size = CGSizeMake(100, 100);
          UIGraphicsBeginImageContextWithOptions(size, YES, 0);
          [[UIColor whiteColor] setFill];
          UIRectFill(CGRectMake(0, 0, size.width, size.height));
          UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
          UIGraphicsEndImageContext();

          meta.snapshot = image;

          AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:@{}];

          IGVideoComposition *composition = [[%c(IGVideoComposition) alloc] init];

          IGVideoClip *clip = [[%c(IGVideoClip) alloc] initWithAsset:asset position:0 sourceType:0];
          [composition addClip:clip];
          IGVideoInfo *info = [[%c(IGVideoInfo) alloc] init];
          info.video = composition;
          
          dispatch_async(dispatch_get_main_queue(), ^{
            status.labelText = localizedString(@"LOADING_VIEWS");
            [main presentCameraWithMetadata:meta mode:1];

            IGCameraNavigationController *camera = [main cameraController];

            IGVideoEditorViewController *editor = [[%c(IGVideoEditorViewController) alloc] initWithOrigin:2 videoInfo:info mediaMetadata:meta];

            [camera pushViewController:editor animated:YES];

            [status hide:YES afterDelay:1.0];
          });

        });
      }
    }
  }
  %orig;
}

// muting in instagram 7.14+(?)
- (void)reloadWithNewObjects:(NSArray*)items context:(id)arg2 synchronus:(char)arg3 forceAnimated:(char)arg4 completionBlock:(id)arg5 {
  if (!(enabled && (muteFeed || hideSponsored))) return %orig;
  BOOL isMainFeed = [self isKindOfClass:[%c(IGMainFeedViewController) class]];
  if (!isMainFeed) return %orig;

  NSArray *final = [self getMutedList:items];

  return %orig(final, arg2, arg3, arg4, arg5);
}

// muting in instagram 7.14+(?)
- (void)reloadWithNewObjects:(NSArray*)items {
  if (!(enabled && (muteFeed || hideSponsored))) return %orig;
  BOOL isMainFeed = [self isKindOfClass:[%c(IGMainFeedViewController) class]];
  if (!isMainFeed) return %orig;

  NSArray *final = [self getMutedList:items];
  return %orig(final);
}


%new
- (NSArray*)getMutedList:(NSArray*)items {
  NSMutableArray *origCopy = [items mutableCopy];

  NSMutableArray *toRemove = [[NSMutableArray alloc] init];
  for (IGFeedItem *item in items) {
    BOOL contains = [muted containsObject:item.user.username];
    if ((muteFeed && contains && muteMode == 0) || (muteFeed && !contains && muteMode == 1) || (item.sponsoredPostInfo && hideSponsored)) {
      [toRemove addObject:item];
    }
  }

  for (IGFeedItem *removable in toRemove) {
    [origCopy removeObject:removable];
  }

  return [origCopy copy];
}
%end

// // replaced with IGFeedViewController_DEPRECATED in 7.16
// %hook IGFeedViewController
// - (id)initWithFeedNetworkSource:(id)src feedLayout:(int)layout showsPullToRefresh:(BOOL)control {
//   id thing = %orig;
//   if (enabled && mainGrid && [src class] == [%c(IGMainFeedNetworkSource) class]) {
//     [self setFeedLayout:2];
//   }
//   return thing;
// }

// - (void)feedItemActionCellDidTapMoreButton:(IGFeedItemActionCell*)cell {
//   cachedItem = cell.feedItem;
//   %orig;
// }

// - (void)actionSheetDismissedWithButtonTitled:(NSString*)title {
//   if (enabled) {
//     IGFeedItem *item = cachedItem;
//     if ([title isEqualToString:instaSave]) {
//       return saveFeedItem(item);
//     } else if ([title isEqualToString:localizedString(@"SHARE")] && saveActions && saveMode == 1) {
//       if (item.user == [InstaHelper currentUser]) return %orig;
//       NSURL *link = [NSURL URLWithString:[item permalink]];
//       UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
//         initWithActivityItems:@[link]
//         applicationActivities:nil];
//       return [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:nil];
//     }
//   }
//   %orig;
// }

// // muting in instagram 7.14+(?)
// - (void)reloadWithNewObjects:(NSArray*)items context:(id)arg2 synchronus:(char)arg3 forceAnimated:(char)arg4 completionBlock:(/*^block*/id)arg5 {
// if (!(enabled && (muteFeed || hideSponsored))) return %orig;
// BOOL isMainFeed = [self isKindOfClass:[%c(IGMainFeedViewController) class]];
// if (!isMainFeed) return %orig;

// NSArray *final = [self getMutedList:items];

// return %orig(final, arg2, arg3, arg4, arg5);
// }

// // muting in instagram 7.14+(?)
// - (void)reloadWithNewObjects:(NSArray*)items {
//   if (!(enabled && (muteFeed || hideSponsored))) return %orig;
//   BOOL isMainFeed = [self isKindOfClass:[%c(IGMainFeedViewController) class]];
//   if (!isMainFeed) return %orig;

//   NSArray *final = [self getMutedList:items];

//   return %orig(final);
// }


// %new
// - (NSArray*)getMutedList:(NSArray*)items {
//   NSMutableArray *origCopy = [items mutableCopy];

//   NSMutableArray *toRemove = [[NSMutableArray alloc] init];
//   for (IGFeedItem *item in items) {
//     BOOL contains = [muted containsObject:item.user.username];
//     if ((muteFeed && contains && muteMode == 0) || (muteFeed && !contains && muteMode == 1) || (item.sponsoredPostInfo && hideSponsored)) {
//       [toRemove addObject:item];
//     }
//   }

//   for (IGFeedItem *removable in toRemove) {
//     [origCopy removeObject:removable];
//   }

//   return [origCopy copy];
// }
// %end

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
  }
  return %orig;
  
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

// deprecated at some point
// %hook IGDirectedPost
// // instagram > 7.14
// - (void)performRead {
//   if (enabled && disableDMRead) {
//     return;
//   }
//   %orig;
// }
// // instagram > 7.14
// - (BOOL)isRead {
//   if (enabled && disableDMRead) {
//     return false;
//   }
//   return %orig;
// }
// // instagram > 7.14
// - (void)setIsRead:(BOOL)read {
//   if (enabled && disableDMRead) {
//     return %orig(NO);
//   }
//   return %orig;
// }
// %end

// %hook IGDirectedPostRecipient
// // instagram > 7.14
// - (BOOL)hasRead {
//   if (enabled && disableDMRead) {
//     return false;
//   }
//   return %orig;
// }
// // instagram > 7.14
// - (void)setHasRead:(BOOL)read {
//   if (enabled && disableDMRead) {
//     return %orig(NO);
//   }
//   return %orig;
// }
// %end

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
    IGUserDetailViewController *profileView = (IGUserDetailViewController*)currentController;
    IGUser *curUser = [InstaHelper currentUser];

    if ([profileView.user.username isEqualToString:curUser.username]) {
      return [NSNumber numberWithInt:fakeFollowing];
    }
  }
  return %orig;
}

// fake follower count

- (id)followerCount {
  UIViewController *currentController = [InstaHelper currentController];

  BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

  if (enabled && isProfileView && fakeFollowers) {
    IGUserDetailViewController *profileView = (IGUserDetailViewController*)currentController;
    IGUser *curUser = [InstaHelper currentUser];

    if ([profileView.user.username isEqualToString:curUser.username]) {
      return [NSNumber numberWithInt:fakeFollowers];
    }
  }
  return %orig;
}

- (BOOL)isVerified {
  UIViewController *currentController = [InstaHelper currentController];

  BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

  if (enabled && isProfileView && fakeVerified) {
    IGUserDetailViewController *profileView = (IGUserDetailViewController*)currentController;
    IGUser *curUser = [InstaHelper currentUser];

    if ([profileView.user.username isEqualToString:curUser.username]) {
      return YES;
    }
  }
  return %orig;
}
%end

// open links in app

%hook IGUserDetailHeaderView 
- (void)coreTextView:(id)view didTapOnString:(id)str URL:(NSURL*)url {
  if (!openExternalURL(url)) {
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
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop 
    target:self action:@selector(closeController)];
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
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self 
      action:@selector(callShare:)];
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
      otherButtonTitles:localizedString(@"SAVE_PHOTO"), localizedString(@"ZOOM"), nil];
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
    saveVideo(media);
  } else if (popup.tag == 182) {
    if (buttonIndex == 0) {
      IGPhoto *media = ((IGDirectPhoto *)self.content).photo;
      savePhoto(media);
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

%hook IGCoreTextView
- (void)layoutSubviews {
  if (enabled) {
    // set property to know if gestures have been set yet
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
  // share text only
  UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
    initWithActivityItems:@[[self.styledString.attributedString string]]
    applicationActivities:nil];
  [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:nil];
}


// unpadded views
-(BOOL)handleTapAtPoint:(CGPoint)point forTouchEvent:(unsigned)arg2 {
  NSURL *url = [self urlAtPoint:point];
  if (url) {
   if ((![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"]) || !openExternalURL(url)) {
    return %orig;
  }
  return true;
}
return false;
}

// comment views seem to be padded, not sure about what else
-(BOOL)handlePaddedTapAtPoint:(CGPoint)point forTouchEvent:(unsigned)arg2 fromLongTap:(char)arg3 {
  NSURL *url = [self urlAtPoint:point];
  if (url) {
    if ((![url.scheme isEqualToString:@"http"] && ![url.scheme isEqualToString:@"https"]) || !openExternalURL(url)) {
      return %orig;
    }
    return true;
  }
  return false;
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

%hook IGAuthHelper
- (BOOL)hasMaximumNumberOfAccounts {
  return NO;
}
%end

%hook IGProfilePictureImageView
- (void)didMoveToSuperview {
  if (enabled) {
    UIView *superView = (UIView*)[self nextResponder];
    BOOL isProfileView = [superView isKindOfClass:[%c(IGUserDetailHeaderView) class]];
    if (!isProfileView) return %orig;
    [self setDidTap:NO];

    [self setUserInteractionEnabled:YES];
    self.buttonDisabled = NO;

    // double tap 
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];


    // single tap -- original
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail: doubleTap];

    [self addGestureRecognizer:singleTap];

  } else {
    %orig;
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
- (void)singleTapped:(UITapGestureRecognizer *)longPress {
  [self setDidTap:NO];
  [self tapped:self.profilePicButton];
}

%new
- (void)doubleTapped:(UITapGestureRecognizer *)longPress {
  [self setDidTap:YES];
  [self displayProfilePic];
}

%new
- (BOOL)didTap {
  NSNumber *number = objc_getAssociatedObject(self, @selector(didTap));
  return [number boolValue]; 
}

%new
- (void)setDidTap:(BOOL)value {
  NSNumber *number = [NSNumber numberWithBool: value];
  objc_setAssociatedObject(self, @selector(didTap), number, OBJC_ASSOCIATION_RETAIN);
}

-(void)tapped:(id)recognizer {
  if ([self didTap]) return;
  %orig;
  [self setDidTap:![self didTap]];
}

%new
-(void)displayProfilePic {
  NSMutableArray *photos = [[NSMutableArray alloc] init];
  InstaBetterPhoto *photo = [[InstaBetterPhoto alloc] init];

  if (self.user && self.user.username) {
    photo.attributedCaptionCredit = [[NSMutableAttributedString alloc] initWithString:self.user.username attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
  }

  [photos addObject:photo];

  NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];

  // remove the stupid low-res limitation from profile pics
  NSURL *imgUrl = self.user.profilePicURL;
  NSString *tempString = [imgUrl absoluteString];
  tempString = [tempString stringByReplacingOccurrencesOfString:@"s150x150/" withString:@""];
  imgUrl = [NSURL URLWithString:tempString];
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
%hook IGActionSheetCallbackProxy
-(void)actionSheetDismissedWithButtonTitled:(NSString*)title {
  if (enabled) {
    UIViewController *currentController = [InstaHelper currentController];
    BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];
    if (isProfileView) {
      IGUserDetailViewController *userView = (IGUserDetailViewController *) currentController;
      if ([title isEqualToString:instaMute]) {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
        [muted addObject:userView.user.username];
        [prefs setValue:muted forKey:@"muted_users"];
        [prefs writeToFile:prefsLoc atomically:NO];
        return;
      } else if ([title isEqualToString:instaUnmute]) {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
        [muted removeObject:userView.user.username];
        [prefs setValue:muted forKey:@"muted_users"];
        [prefs writeToFile:prefsLoc atomically:NO];
        return;
      }
    }
  }
  %orig;
}
%end

%hook IGActionSheet
- (void)show {
  if (enabled) {
    UIViewController *currentController = [InstaHelper currentController];

    BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];
    BOOL isWebView = [currentController isKindOfClass:[%c(IGWebViewController) class]];
    IGUserDetailViewController *userView = (IGUserDetailViewController *) currentController;

    BOOL responds = [self respondsToSelector:@selector(buttonWithTitle:style:image:accessibilityIdentifier:)];
    // NSLog(@"RESPONDS %d", responds);
    if (isProfileView && !cachedItem && !self.titleLabel.text) {
      IGUser *current = [InstaHelper currentUser];
      if ([current.username isEqualToString:userView.user.username]) return %orig;
      if ([muted containsObject:userView.user.username]) {
        if (responds) {
          [self addButtonWithTitle:instaUnmute style:0 image:nil accessibilityIdentifier:nil];
        } else {
          [self addButtonWithTitle:instaUnmute style:0];
        }
      } else {
        if (responds) {
          [self addButtonWithTitle:instaMute style:0 image:nil accessibilityIdentifier:nil];
        } else {
          [self addButtonWithTitle:instaMute style:0];
        }
      }
    } else if (!self.titleLabel.text && !isWebView) {
      IGUser *current = [InstaHelper currentUser];
      if (showRepost && cachedItem && cachedItem.user != current) {
        [self addButtonWithTitle:localizedString(@"REPOST") style:0 image:nil accessibilityIdentifier:nil];
      }
      if (saveActions && saveMode == 1) { 
        if (responds) {
          [self addButtonWithTitle:instaSave style:0 image:nil accessibilityIdentifier:nil];
          
        } else {
          [self addButtonWithTitle:instaSave style:0];
        }
        
        if (cachedItem && cachedItem.user == current) {
        } else {
          if (responds) {
            [self addButtonWithTitle:localizedString(@"SHARE") style:0 image:nil accessibilityIdentifier:nil]; 
          } else {
            [self addButtonWithTitle:localizedString(@"SHARE") style:0]; 
          }
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
    NSMutableArray *copied = [arr mutableCopy];
    NSMutableArray *toRemove = [[NSMutableArray alloc] init];
    NSUInteger index = 0;
    for (NSDictionary* dict in arr) {
      NSArray *links = [dict valueForKeyPath:@"args.links"];
      if ([links count] == 1) {
        NSArray* words = [[dict valueForKeyPath:@"args.text"] componentsSeparatedByString:@" "];
        if ([words count] == 0) continue;
        BOOL contains = [muted containsObject:[words objectAtIndex:0]];
        if ((contains && muteMode == 0) || (!contains && muteMode == 1)) {
          [toRemove addObject:dict];
        }
      }
      index++;
    }
    for (id removable in toRemove) {
      if (![toRemove containsObject:removable]) continue;
      [copied removeObject:removable];
    }
    arr = [copied copy];
  }
  return %orig;
}
%end


%hook IGUserDetailViewController
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
%end

%hook IGMainFeedViewController
// instagram > 7.14
// deprecated
// - (BOOL)shouldHideFeedItem:(IGFeedItem *)item {
//   if (enabled) {
//     BOOL contains = [muted containsObject:item.user.username];
//     if ((contains && muteMode == 0) || (!contains && muteMode == 1)) {
//       return YES;
//     } else {
//       return %orig;
//     }
//   } else {
//     return %orig;
//   }
// }

- (void)viewDidLoad {
  %orig;
  if (!(enabled && layoutSwitcher)) return;
  if (!gridItem || !listItem) {
    gridItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"feedtoggle-grid-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(changeView)];
    listItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"feedtoggle-list-icon.png"] style:UIBarButtonItemStylePlain target:self action:@selector(changeView)];
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
    // IGFeedItemPreviewingHandler *handler = [[%c(IGFeedItemPreviewingHandler) alloc] initWithController:self];
    // [self setFeedPreviewingDelegate:handler];
    [self setFeedLayout:2];
    [self.navigationItem setLeftBarButtonItem:listItem animated:YES];
  }
}
%end

// %hook IGFeedItemTextCell
// - (IGStyledString *)styledStringForLikesWithFeedItem:(IGFeedItem *)item {
//     IGStyledString *styled = %orig;
//     if (enabled && showPercents) {
//       id mediaId = nil;
//       if ([item respondsToSelector:@selector(getMediaId)]) {
//         mediaId = [item getMediaId];
//       } else {
//         mediaId = [item mediaId];
//       }
//       int likeCount = [[likesDict objectForKey:mediaId] intValue];
//       if (likeCount && likeCount == item.likeCount) {
//         return styled;
//       } else {
//         if (item.user.followerCount) {
//           [likesDict setObject:[NSNumber numberWithInt:item.likeCount] forKey:mediaId];
//           int followers = [item.user.followerCount intValue];
//           float percent = ((float)item.likeCount / (float)followers) * 100.0;
//           NSString *display = [NSString stringWithFormat:@" (%.01f%%)", percent];
//           NSMutableAttributedString *original = [[NSMutableAttributedString alloc] initWithAttributedString:[styled attributedString]];
//           NSMutableDictionary *attributes = [[original attributesAtIndex:0 effectiveRange:NULL] mutableCopy];
//           UIColor *col = nil;
//           if (percent <= 20.0) {
//             col = [UIColor redColor];
//           } else if (percent > 20.0 && percent <= 45.0) {
//             col = [UIColor orangeColor];
//           } else if (percent > 45.0 && percent <= 72.0) {
//             col = [UIColor yellowColor];
//           } else {
//             col = [UIColor greenColor];
//           }
//           [attributes setObject:col forKey:NSForegroundColorAttributeName];
//           NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:display attributes:attributes];
//           [original appendAttributedString:formatted];
//           [styled setAttributedString:original];
//           return styled;
//         }
//       }
//     }
//     return styled;
// }
// %end

// %hook IGFeedItem
// - (id)initWithDictionary:(id)data {
//   id item = %orig;
//   if (enabled && showPercents) {
//     UIViewController *currentController = [InstaHelper currentController];

//     BOOL isPostsView = [currentController isKindOfClass:[%c(IGPostsFeedViewController) class]];
//     BOOL isMainView = [currentController isKindOfClass:[%c(IGMainFeedViewController) class]];
//     if (isPostsView || isMainView) {
//       dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//       dispatch_async(queue, ^{
//         [self.user fetchAdditionalUserDataWithCompletion:nil];
//       });
//     }
//   }
//   return item;
// }
// %end

// %hook AppDelegate
// - (void)applicationDidEnterBackground:(id)application {
//   if (enabled && showPercents) {
//     [likesDict removeAllObjects];
//   }
//   %orig;
// }
// %end

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
  saveFeedItem(item);
}

%new
- (void)shareItem:(id)sender {
  IGFeedItem *item = self.feedItem;
  NSURL *link = [NSURL URLWithString:[item permalink]];
  // share Instagram link, direct link, actual image
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

// deprecated in Instagram >= 7.15
// - (void)actionSheetDismissedWithButtonTitled:(NSString *)title {
//   if (enabled) {
//     if ([title isEqualToString:instaSave]) {
//       IGFeedItem *item = self.feedItem;
//       saveFeedItem(item);
//     } else if ([title isEqualToString:localizedString(@"SHARE")] && saveActions && saveMode == 1) {
//       IGFeedItem *item = self.feedItem;
//       if (item.user == [InstaHelper currentUser]) return %orig;
//       NSURL *link = [NSURL URLWithString:[item permalink]];
//       UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
//         initWithActivityItems:@[link]
//         applicationActivities:nil];
//       [[InstaHelper rootViewController] presentViewController:activityViewController animated:YES completion:nil];
//     } else {
//       %orig;
//     }
//   } else {
//     %orig;
//   }
// }
%end

// custom locations
%hook IGLocationPickerViewController
- (void)viewDidLoad {
  %orig;
  if (!(enabled && customLocations)) return;
  UIBarButtonItem *userButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location-pin-inactive.png"] style:UIBarButtonItemStylePlain target:self action:@selector(selectCustom)];
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
// deprecated at some point
// %hook IGFeedItemTimelineLayoutAttributes
// - (BOOL)sponsoredContext {
//   if (enabled && hideSponsored) {
//     return false;
//   } else {
//     return %orig;
//   }
// }
// %end

%hook IGFeedItemHeader
// Instagram 7.17.1.. OTA 
-(void)onChevronTapped:(id)arg1 {
  if (enabled) {
    IGFeedItem *feedItem = nil;
    BOOL responds = [self respondsToSelector:@selector(viewModel)];
    if (responds) {
      IGFeedItemHeaderViewModel *model = [self viewModel];
      feedItem = [model feedItem];
    } else {
      feedItem = [self feedItem];
    }

    if (feedItem) {
      cachedItem = feedItem;
    }

  }
  %orig;
}

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

    [InstaHelper setupPhotoAlbumNamed:@"InstaBetter" withCompletionHandler:^(ALAssetsLibrary *assetsLibrary, ALAssetsGroup *group) {}];

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
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "substrate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <lib/NYTPhotosViewController.h>
#import "IGHeaders.h"
#import "MBProgressHUD.h"
#import <lib/UIAlertView+Blocks.h>
#import <notify.h>

#define ibBundle @"/Library/Application Support/InstaBetter/InstaBetterResources.bundle"
NSBundle *bundle = [[NSBundle alloc] initWithPath:ibBundle];
NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];

static NSMutableArray *muted = nil;
static NSMutableDictionary *likesDict = [[NSMutableDictionary alloc] init];

static BOOL enabled = YES;
static BOOL showPercents = YES;
static BOOL hideSponsored = YES;
static int muteMode = 0;
static BOOL saveActions = YES;
static BOOL followStatus = YES;
static BOOL customLocations = YES;
static BOOL openInApp = YES;
static BOOL disableDMRead = NO;
static BOOL loadHighRes = NO;
static BOOL mainGrid = NO;
static int audioMode = 1;
static int videoMode = 1;
static int alertMode = 1;
static int fakeFollowers = nil;
static int fakeFollowing = nil;
static BOOL enableTimestamps = YES;
static int timestampFormat = 0;
static BOOL alwaysTimestamp = NO;

float origPosition = nil;
int ringerState;
static BOOL ringerMuted;

static NSString *instaMute = @"Mute";
static NSString *instaUnmute = @"Unmute";
static NSString *instaSave = @"Save Media";
static NSString *prefsLoc = @"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist";

static void initPrefs() {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
    NSMutableArray *vals = [[NSMutableArray alloc] init];
    [prefs setValue:@YES forKey:@"enabled"];
    [prefs setValue:@YES forKey:@"hide_sponsored"];
    [prefs setValue:@YES forKey:@"show_percents"];
    [prefs setValue:@YES forKey:@"follow_status"];
    [prefs setValue:@YES forKey:@"custom_locations"];
    [prefs setValue:@YES forKey:@"save_actions"];
    [prefs setValue:@NO forKey:@"disable_read_notification"];
    [prefs setValue:@NO forKey:@"zoom_hi_res"];
    [prefs setValue:@NO forKey:@"main_grid"];
    [prefs setValue:0 forKey:@"mute_mode"];
    [prefs setValue:[NSNumber numberWithInt:1] forKey:@"alert_mode"];
    [prefs setValue:[NSNumber numberWithInt:1] forKey:@"audio_mode"];
    [prefs setValue:nil forKey:@"fake_follower_count"];
    [prefs setValue:nil forKey:@"fake_following_count"];
    [prefs setValue:vals forKey:@"muted_users"];
    [prefs setValue:@NO forKey:@"always_timestamp"];
    [prefs setValue:@YES forKey:@"enable_timestamp"];
    [prefs setValue:[NSNumber numberWithInt:0] forKey:@"timestamp_format"];
    [prefs writeToFile:prefsLoc atomically:YES];
}

static NSDictionary* updatePrefs() {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];

    if (!muted) {
        muted = [[NSMutableArray alloc] init];
    }
    if (prefs) {
      enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
      showPercents = [prefs objectForKey:@"show_percents"] ? [[prefs objectForKey:@"show_percents"] boolValue] : YES;
      hideSponsored = [prefs objectForKey:@"hide_sponsored"] ? [[prefs objectForKey:@"hide_sponsored"] boolValue] : YES;
      saveActions = [prefs objectForKey:@"save_actions"] ? [[prefs objectForKey:@"save_actions"] boolValue] : YES;
      followStatus = [prefs objectForKey:@"follow_status"] ? [[prefs objectForKey:@"follow_status"] boolValue] : YES;
      customLocations = [prefs objectForKey:@"custom_locations"] ? [[prefs objectForKey:@"custom_locations"] boolValue] : YES;
      openInApp = [prefs objectForKey:@"app_browser"] ? [[prefs objectForKey:@"app_browser"] boolValue] : YES;
      disableDMRead = [prefs objectForKey:@"disable_read_notification"] ? [[prefs objectForKey:@"disable_read_notification"] boolValue] : NO;
      loadHighRes = [prefs objectForKey:@"zoom_hi_res"] ? [[prefs objectForKey:@"zoom_hi_res"] boolValue] : NO;
      mainGrid = [prefs objectForKey:@"main_grid"] ? [[prefs objectForKey:@"main_grid"] boolValue] : NO;
      muteMode = [prefs objectForKey:@"mute_mode"] ? [[prefs objectForKey:@"mute_mode"] intValue] : 0;
      alertMode = [prefs objectForKey:@"alert_mode"] ? [[prefs objectForKey:@"alert_mode"] intValue] : 1;
      audioMode = [prefs objectForKey:@"audio_mode"] ? [[prefs objectForKey:@"audio_mode"] intValue] : 1;
      videoMode = [prefs objectForKey:@"video_mode"] ? [[prefs objectForKey:@"video_mode"] intValue] : 1;
      fakeFollowers = [prefs objectForKey:@"fake_follower_count"] ? [[prefs objectForKey:@"fake_follower_count"] intValue] : nil;
      fakeFollowing = [prefs objectForKey:@"fake_following_count"] ? [[prefs objectForKey:@"fake_following_count"] intValue] : nil;

      alwaysTimestamp = [prefs objectForKey:@"always_timestamp"] ? [[prefs objectForKey:@"always_timestamp"] boolValue] : NO;
      enableTimestamps = [prefs objectForKey:@"enable_timestamp"] ? [[prefs objectForKey:@"enable_timestamp"] boolValue] : YES;
      timestampFormat = [prefs objectForKey:@"timestamp_format"] ? [[prefs objectForKey:@"timestamp_format"] intValue] : 0;

      [muted removeAllObjects];
      [muted addObjectsFromArray:[prefs objectForKey:@"muted_users"]];
    } else {
      initPrefs();
      return updatePrefs();
    }

    return prefs;

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
      [data writeToURL:tempURL atomically:YES];
      [%c(IGAssetWriter) writeVideoToInstagramAlbum:tempURL completionBlock:nil];
      dispatch_async(dispatch_get_main_queue(), ^{
        status.customView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"37x-Checkmark@2x" ofType:@"png"]]];
        status.mode = MBProgressHUDModeCustomView;
        status.labelText = @"Saved!";

        [status hide:YES afterDelay:1.0];
      });
    }];
  });
}

static void saveMedia(IGPost *post) {
  if (enabled && saveActions) {
    UIWindow *appWindow = [[[UIApplication sharedApplication] delegate] window];
    MBProgressHUD *status = [MBProgressHUD showHUDAddedTo:appWindow animated:YES];
    status.labelText = @"Saving";
    if (post.mediaType == 1) {
      NSString *versionURL = highestResImage(post.photo.imageVersions);
    
      NSURL *imgUrl = [NSURL URLWithString:versionURL];
      dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      dispatch_async(queue, ^{
        NSData *imgData = [NSData dataWithContentsOfURL:imgUrl];
        UIImage *img = [UIImage imageWithData:imgData];
        IGAssetWriter *postImageAssetWriter = [[%c(IGAssetWriter) alloc] initWithImage:img metadata:nil];
        [postImageAssetWriter writeToInstagramAlbum];
        dispatch_async(dispatch_get_main_queue(), ^{
          status.customView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"37x-Checkmark@2x" ofType:@"png"]]];
          status.mode = MBProgressHUDModeCustomView;
          status.labelText = @"Saved!";

          [status hide:YES afterDelay:1.0];
        });
      });

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

%group instaHooks

// double-tap like confirmation

%hook IGFeedItemVideoView
-(void)onDoubleTap:(UITapGestureRecognizer*)tap {
  if (enabled) {
    IGPost *post = ((IGFeedItemVideoView*)[tap view]).post;
    NSDate *now = [NSDate date];
    BOOL needsAlert = [now timeIntervalSinceDate:[post.takenAt date]] > 86400.0f;
    if (!post.hasLiked && (alertMode == 2 || (alertMode == 1 && needsAlert))) {
      [UIAlertView showWithTitle:@"Like Video?"
        message:@"Did you want to like this video?"
        cancelButtonTitle:nil
        otherButtonTitles:@[@"Confirm", @"Cancel"]
        tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
          if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Confirm"]) {
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
-(void)onDoubleTap:(id)tap {
  IGPost *post = ((IGFeedPhotoView*)[tap view]).parentCellView.post;
  NSDate *now = [NSDate date];
  BOOL needsAlert = [now timeIntervalSinceDate:[post.takenAt date]] > 86400.0f;

  if (!post.hasLiked && (alertMode == 2 || (alertMode == 1 && needsAlert))) {
    [UIAlertView showWithTitle:@"Like photo?"
    message:@"Did you want to like this photo?"
    cancelButtonTitle:nil
    otherButtonTitles:@[@"Confirm", @"Cancel"]
    tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
      if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Confirm"]) {
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
-(id)initWithFeedNetworkSource:(id)src feedLayout:(int)layout showsPullToRefresh:(char)control {
  if (mainGrid && [src class] == [%c(IGMainFeedNetworkSource) class]) {
    return %orig(src, 2, control);
  }
  return %orig;
}
%end

// auto play audio

%hook IGFeedVideoPlayer
-(void)setReadyToPlay:(char)arg1 {
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
-(void)showRatingAlert {
  if (enabled && hideSponsored) {
    return;
  } else {
    return %orig;
  }
}
%end

// disable DM seen checks


%hook IGDirectThreadViewController
-(void)sendSeenTimestampForContent:(id)arg1 {
  if (enabled && disableDMRead) {
    return;
  }
  %orig;
}
%end

%hook IGDirectedPost
-(void)performRead {
  if (enabled && disableDMRead) {
    return;
  }
  %orig;
}
-(BOOL)isRead {
  if (enabled && disableDMRead) {
    return false;
  }
  return %orig;
}
-(void)setIsRead:(BOOL)read {
  if (enabled && disableDMRead) {
    return %orig(NO);
  }
  return %orig;
}
%end

%hook IGDirectedPostRecipient
-(BOOL)hasRead {
  if (enabled && disableDMRead) {
    return false;
  }
  return %orig;
}
-(void)setHasRead:(BOOL)read {
  if (enabled && disableDMRead) {
    return %orig(NO);
  }
  return %orig;
}
%end

// follow status

%hook IGUser
- (void)onFriendStatusReceived:(NSDictionary*)status fromRequest:(id)req {
  if (enabled && followStatus) {
    AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
    IGRootViewController *rootViewController = (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
    UIViewController *currentController = rootViewController.topMostViewController;

    BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

    if (isProfileView) {
      IGUserDetailViewController *userView = (IGUserDetailViewController*) currentController;
      CGRect oldFrame = userView.headerView.followButton.frame;
      CGRect screenRect = [[UIScreen mainScreen] bounds];
      CGFloat screenWidth = screenRect.size.width;
      oldFrame.origin.y = oldFrame.size.height + oldFrame.origin.y;
      oldFrame.size.width = screenWidth - oldFrame.origin.x;
      UILabel *statusLabel = [[UILabel alloc] initWithFrame:oldFrame];
      int followed_by = [[status objectForKey:@"followed_by"] intValue];
      int following = [[status objectForKey:@"following"] intValue];
      if (followed_by == 1 && following == 1) {
        statusLabel.text = @"You follow each other";
      } else if (followed_by == 1) {
        statusLabel.text = [NSString stringWithFormat:@"%@ follows you", self.username];
      } else if (followed_by == 0) {
        statusLabel.text = [NSString stringWithFormat:@"%@ does not follow you", self.username];
      }
      statusLabel.textColor = [UIColor colorWithWhite:0.333333 alpha:1.0];
      statusLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
      [userView.headerView addSubview:statusLabel];
    }
  }

  %orig;
}

// fake following count

-(id)followingCount {
  AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
  IGRootViewController *rootViewController = (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
  UIViewController *currentController = rootViewController.topMostViewController;

  BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

  if (enabled && isProfileView && fakeFollowing) {
    return [NSNumber numberWithInt:fakeFollowing];
  }
  return %orig;
}

// fake follower count

-(id)followerCount {
  AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
  IGRootViewController *rootViewController = (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
  UIViewController *currentController = rootViewController.topMostViewController;

  BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

  if (enabled && isProfileView && fakeFollowers) {
    return [NSNumber numberWithInt:fakeFollowers];
  }
  return %orig;
}
%end


// open links in app

%hook IGUserDetailHeaderView 
-(void)coreTextView:(id)view didTapOnString:(id)str URL:(id)url {
  if (enabled && openInApp) {
    AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
    IGRootViewController *rootViewController = (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
    [%c(IGURLHelper) openExternalURL:url controller:rootViewController modal:YES controls:YES completionHandler:nil];
  } else {
    %orig;
  }
}
%end

// save images and videos in direct messages

%hook IGDirectContentExpandableCell
-(void)layoutSubviews{
  if (enabled) {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(callShare:)];
    [longPress setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];
    [self.contentMenuLongPressRecognizer requireGestureRecognizerToFail:longPress];
    [longPress setMinimumPressDuration:1.5];
    [self setUserInteractionEnabled:YES];
    [self addGestureRecognizer:longPress];
  }
  %orig;
}

%new
-(void)callShare:(UIGestureRecognizer *)longPress {
  if (longPress.state != UIGestureRecognizerStateBegan) return;

  if ([self.content isKindOfClass:[%c(IGDirectPhoto) class]]) {
    NSMutableArray *photos = [[NSMutableArray alloc] init];
    InstaBetterPhoto *photo = [[InstaBetterPhoto alloc] init];

    [photos addObject:photo];

    NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];
    photosViewController.delegate = self;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:photosViewController animated:YES completion:nil];

    IGPhoto *media = ((IGDirectPhoto*)self.content).photo;
    
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
  } else if ([self.content isKindOfClass:[%c(IGDirectVideo) class]]) {
    // confirm that we want to save the video
    
    UIActionSheet *actions = [[UIActionSheet alloc]
      initWithTitle:@"Actions"
      delegate:self
      cancelButtonTitle:@"Cancel"
      destructiveButtonTitle:nil
      otherButtonTitles:@"Save Video", nil];

    [actions showInView:[UIApplication sharedApplication].keyWindow];
  }
}

%new
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex != 0) return;
  
  IGVideo *media = ((IGDirectVideo*)self.content).video;
  NSString *versionURL = highestResImage(media.videoVersions);

  NSURL *vidURL = [NSURL URLWithString:versionURL];

  saveVideo(vidURL, nil);
}
%end

// share sheet text

%hook IGCoreTextView
-(void)layoutSubviews {
  if (enabled) {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(callShare:)];
    [longPress setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];
    [longPress setMinimumPressDuration:1];
    [self addGestureRecognizer:longPress];
  }
  %orig;
}

%new
-(void)callShare:(UIGestureRecognizer *)longPress {
  UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
        initWithActivityItems:@[[self.styledString.attributedString string]]
        applicationActivities:nil];
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityViewController animated:YES completion:nil];
}
%end

%hook IGFeedMediaView
-(void)layoutSubviews {
  if (enabled) {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    [longPress setDelegate:(id<UILongPressGestureRecognizerDelegate>)self];
    [longPress setMinimumPressDuration:1];
    [self addGestureRecognizer:longPress];
  }
  %orig;
}

%new
-(void)longPressed:(UIGestureRecognizer *)longPress {
  NSMutableArray *photos = [[NSMutableArray alloc] init];
  IGFeedItemPhotoCell *photoCell = (IGFeedItemPhotoCell*) self.superview.superview;
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

  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:photosViewController animated:YES completion:nil];
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

-(void)setUserInteractionEnabled:(BOOL)opt {
  if (enabled) {
    %orig(YES);
  } else {
    %orig;
  }
}

%new
-(void)longPressed:(UIGestureRecognizer *)longPress {
  NSMutableArray *photos = [[NSMutableArray alloc] init];
  InstaBetterPhoto *photo = [[InstaBetterPhoto alloc] init];
  photo.image = self.originalImage;
  if (self.user && self.user.username) {
    photo.attributedCaptionCredit = [[NSMutableAttributedString alloc] initWithString:self.user.username attributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor]}];
  }
  [photos addObject:photo];

  NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos];
  [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:photosViewController animated:YES completion:nil];
}
%end

// action sheet manager

%hook IGActionSheet
- (void)show {
  if (enabled) {
    AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
    IGRootViewController *rootViewController = (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
    UIViewController *currentController = rootViewController.topMostViewController;

    BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];
    BOOL isWebView = [currentController isKindOfClass:[%c(IGWebViewController) class]];
    if (isProfileView && [self.buttons count] == 5) {
        IGUserDetailViewController *userView = (IGUserDetailViewController *) currentController;

        IGUser *current = ((IGAuthHelper*)[%c(IGAuthHelper) sharedAuthHelper]).currentUser;
        if ([current.username isEqualToString:userView.user.username]) return %orig;
        if ([muted containsObject:userView.user.username]) {
            [self addButtonWithTitle:instaUnmute style:0];
        } else {
            [self addButtonWithTitle:instaMute style:0];
        }
    } else if (!self.titleLabel.text && !isWebView) {    
      if (saveActions) {   
        [self addButtonWithTitle:instaSave style:0];   
      }    
      [self addButtonWithTitle:@"Share" style:0];    
    }
  }
  %orig;
}
%end

// mute users

%hook IGUserDetailViewController
-(void)actionSheetDismissedWithButtonTitled:(NSString *)title {
  if (enabled) {
    if ([title isEqualToString:instaMute]) {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
        NSMutableArray *keys = [prefs objectForKey:@"muted_users"];
        [keys addObject:self.user.username];
        [prefs setValue:keys forKey:@"muted_users"];
        [prefs writeToFile:prefsLoc atomically:YES];
        updatePrefs();
    } else if ([title isEqualToString:instaUnmute]) {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
        NSMutableArray *keys = [prefs objectForKey:@"muted_users"];
        [keys removeObject:self.user.username];
        [prefs setValue:keys forKey:@"muted_users"];
        [prefs writeToFile:prefsLoc atomically:YES];
        updatePrefs();
    } else {
        %orig;
    }
  } else {
    %orig;
  }
}
%end

%hook IGMainFeedViewController
-(BOOL)shouldHideFeedItem:(IGFeedItem *)item {
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
%end


%hook IGFeedItemTextCell
-(IGStyledString*)styledStringForLikesWithFeedItem:(IGFeedItem*)item {
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
    AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
    IGRootViewController *rootViewController = (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
    UIViewController *currentController = rootViewController.topMostViewController;

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
- (void)applicationDidEnterBackground:(id)arg1 {
  if (enabled && showPercents) {
    [likesDict removeAllObjects];
  }
  %orig;
}
%end

// save media
// 
%hook IGFeedItemActionCell
-(void)actionSheetDismissedWithButtonTitled:(NSString *)title {
  if (enabled) {
    if ([title isEqualToString:instaSave]) {
      IGFeedItem *item = self.feedItem;
      saveMedia(item);
    } else if ([title isEqualToString:@"Share"]) {
      IGFeedItem *item = self.feedItem;
      NSURL *link = [NSURL URLWithString:[item permalink]];
      UIActivityViewController *activityViewController = [[UIActivityViewController alloc] 
        initWithActivityItems:@[link]
        applicationActivities:nil];
      [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:activityViewController animated:YES completion:nil];
    } else {
      %orig;
    }
  } else {
    %orig;
  }
}
%end

%hook IGLocationDataSource
-(NSArray *)locations{
  if (enabled && customLocations) {
    NSArray *thing = %orig;
    if (thing == nil || !self.responseQueryText) {
      return thing;
    }
    NSMutableArray *original = [[NSMutableArray alloc] initWithArray:thing];
    IGLocation *newLoc = [[%c(IGLocation) alloc] initWithDictionary:@{
      @"name": self.responseQueryText,
      @"address": @"",
      @"external_source": @"facebook_places",
      @"facebook_places_id": @2505799649651301,
      @"lat": @"0.0",
      @"lng": @"0.0",
      @"state": @""
    }];
    if (newLoc && original) {
      [original addObject:newLoc];
    }
    return [NSArray arrayWithArray:original];
  } else {
    return %orig;
  }
}
%end


// hide sponsored posts

%hook IGFeedItemTimelineLayoutAttributes
-(BOOL)sponsoredContext {
  if (enabled && hideSponsored) {
    return false;
  } else {
    return %orig;
  }
}
%end


%hook IGFeedItemHeader
-(BOOL)sponsoredPostAllowed {
  if (enabled && hideSponsored) {
    return false;
  } else {
    return %orig;
  }
}

-(void)layoutSubviews {
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
-(void)showTimestamp {
  if (self.timestampLabel.frame.origin.x == origPosition) {
    showTimestamp(self, true);
  }
}
%end

%hook IGFeedItemActionCell
-(BOOL)sponsoredPostAllowed {
  if (enabled && hideSponsored) {
    return false;
  } else {
    return %orig;
  }
}
%end

%hook IGSponsoredPostInfo
-(BOOL)showIcon {
  if (enabled && hideSponsored) {
    return false;
  } else {
    return %orig;
  }
}
-(BOOL)hideCommentButton {
  if (enabled && hideSponsored) {
    return true;
  } else {
    return %orig;
  }
}
-(BOOL)isHoldout {
  if (enabled && hideSponsored) {
    return true;
  } else {
    return %orig;
  }
}
-(BOOL)hideComments {
  if (enabled && hideSponsored) {
    return true;
  } else {
    return %orig;
  }
}
%end

%hook IGAccountSettingsViewController
-(id)settingSectionRows {
  id thing = %orig;
  NSLog(@"THING: %@", thing);
  return [NSArray arrayWithObjects:@0, @1, @2, @3, @4, @5, nil];
}
-(int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2 {
  if (arg2 == 2) {
    return 6;
  }
  return %orig;
}

-(id)tableView:(id)arg1 cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  IGGroupedTableViewCell* cell = %orig;
  if (indexPath.section == 2 && indexPath.row == 5) {
    cell.textLabel.text = @"InstaBetter Settings";
  }
  return cell;
}

-(void)tableView:(id)arg1 didSelectSettingsRow:(int)arg2 {
  if (arg2 == 5) {
    NSLog(@"CALLED!");
    // IBSettingsViewController *settings = [[IBSettingsViewController alloc] init];
    // AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
    // UINavigationController *nav = (UINavigationController *)((IGShakeWindow *)igDelegate.window).rootViewController;
    // [nav pushViewController:settings animated:YES];
  }
  %orig;
}
%end

%end

static void handlePrefsChange(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  updatePrefs();
}

static void setRingerState(uint64_t state) {
  if (state == 0) {
    ringerMuted = YES;
  } else if (state == 1) {
    ringerMuted = NO;
  } else {
    NSLog(@"Received invalid ringer status..this shouldn't happen -- State: %d", (int)state);
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
  setupRingerCheck();

  CFNotificationCenterAddObserver(
    CFNotificationCenterGetDarwinNotifyCenter(), 
    NULL,
    &handlePrefsChange,
    (CFStringRef)@"com.jake0oo0.instabetter/prefsChange",
    NULL, 
    CFNotificationSuspensionBehaviorCoalesce);

  @autoreleasepool {
    %init(instaHooks);
  }
}
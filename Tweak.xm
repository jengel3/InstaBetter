#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "substrate.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "IGHeaders.h"
#import "MBProgressHUD.h"

#define kBundlePath @"/Library/MobileSubstrate/DynamicLibraries/InstaBetterBundle.bundle"
NSBundle *bundle = [[NSBundle alloc] initWithPath:kBundlePath];

static NSMutableArray *muted = nil;
static NSMutableDictionary *likesDict = [[NSMutableDictionary alloc] init];

static BOOL enabled = YES;
static BOOL showPercents = YES;
static BOOL hideSponsored = YES;
static int muteMode = 0;
static BOOL saveActions = YES;
static BOOL followStatus = YES;
static BOOL customLocations = YES;

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
    [prefs setValue:0 forKey:@"mute_mode"];
    [prefs setValue:vals forKey:@"muted_users"];
    [prefs writeToFile:prefsLoc atomically:YES];
}

static void updatePrefs() {
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
      muteMode = [prefs objectForKey:@"mute_mode"] ? [[prefs objectForKey:@"mute_mode"] intValue] : 0;
      [muted removeAllObjects];
      [muted addObjectsFromArray:[prefs objectForKey:@"muted_users"]];
    } else {
      initPrefs();
      updatePrefs();
    }

    [prefs release];
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
          status.customView = [[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"37x-Checkmark@2x" ofType:@"png"]]] autorelease];
          status.mode = MBProgressHUDModeCustomView;
          status.labelText = @"Saved!";

          [status hide:YES afterDelay:1.0];
        });
      });

    } else if (post.mediaType == 2) {
      NSString *versionURL = highestResImage(post.video.videoVersions);
    
      NSURL *vidURL = [NSURL URLWithString:versionURL];
      dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
      dispatch_async(queue, ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:vidURL];

        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
          NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
          NSURL *tempURL = [documentsURL URLByAppendingPathComponent:[vidURL lastPathComponent]];
          [data writeToURL:tempURL atomically:YES];
          [%c(IGAssetWriter) writeVideoToInstagramAlbum:tempURL completionBlock:nil];
          dispatch_async(dispatch_get_main_queue(), ^{
            status.customView = [[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"37x-Checkmark@2x" ofType:@"png"]]] autorelease];
            status.mode = MBProgressHUDModeCustomView;
            status.labelText = @"Saved!";

            [status hide:YES afterDelay:1.0];
          });
        }];
      });
    }
  }
}

%group instaHooks

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
        statusLabel.text = @"You follow eachother";
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
%end

// action sheet manager

%hook IGActionSheet
- (void)show {
  if (enabled) {
    AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
    IGRootViewController *rootViewController = (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
    UIViewController *currentController = rootViewController.topMostViewController;

    BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

    if (isProfileView) {
        IGUserDetailViewController *userView = (IGUserDetailViewController *) currentController;
        if ([muted containsObject:userView.user.username]) {
            [self addButtonWithTitle:instaUnmute style:0];
        } else {
            [self addButtonWithTitle:instaMute style:0];
        }
    } else if (!isProfileView) {
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

// like percentages

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
            NSString *display = [NSString stringWithFormat:@" - %.01f%%", percent];
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
}
%end

// save media

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
    IGLocation *newLoc = [[[%c(IGLocation) alloc] initWithDictionary:@{
      @"name": self.responseQueryText,
      @"address": @"",
      @"external_source": @"facebook_places",
      @"facebook_places_id": @2505799649651301,
      @"lat": @"0.0",
      @"lng": @"0.0",
      @"state": @""
    }] retain];
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

%end

static void handleNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  updatePrefs();
}

%ctor {
    
    updatePrefs();
    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), NULL,
      &handleNotification,
      (CFStringRef)@"com.jake0oo0.instabetter/prefsChange",
      NULL, CFNotificationSuspensionBehaviorCoalesce);
    %init(instaHooks);
}
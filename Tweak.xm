#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "substrate.h"
#import "IGHeaders.h"

static NSMutableArray *muted = nil;
static NSMutableArray *modded = nil;
static NSMutableDictionary *likesDict = [[NSMutableDictionary alloc] init];

static BOOL enabled = YES;
static BOOL showPercents = YES;
static BOOL hideSponsored = YES;
static int muteMode = 0;

static NSString *instaMute = @"Mute";
static NSString *instaUnmute = @"Unmute";
static NSString *prefsLoc = @"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist";

static void initPrefs() {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
    NSMutableArray *vals = [[NSMutableArray alloc] init];
    [prefs setValue:@YES forKey:@"enabled"];
    [prefs setValue:@YES forKey:@"hide_sponsored"];
    [prefs setValue:@YES forKey:@"show_percents"];
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
      muteMode = [prefs objectForKey:@"mute_mode"] ? [[prefs objectForKey:@"mute_mode"] intValue] : 0;
      [muted removeAllObjects];
      [muted addObjectsFromArray:[prefs objectForKey:@"muted_users"]];
    } else {
      initPrefs();
      updatePrefs();
    }

    [prefs release];
}

%group instaHooks

%hook IGUserDetailViewController

%end

%hook IGUser
- (void)onFriendStatusReceived:(NSDictionary*)status {
  AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
  IGRootViewController *rootViewController = (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
  UIViewController *currentController = rootViewController.topMostViewController;

  BOOL isProfileView = [currentController isKindOfClass:[%c(IGUserDetailViewController) class]];

  if (isProfileView) {
    IGUserDetailViewController *userView = (IGUserDetailViewController*) currentController;
    NSLog(@"%@", userView.headerView.infoLabelView.styledString.attributedString);
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:userView.headerView.infoLabelView.frame];
    int followed_by = [[status objectForKey:@"followed_by"] intValue];
    int following = [[status objectForKey:@"following"] intValue];
    if (followed_by == 1 && following == 1) {
      statusLabel.text = @"You follow eachother";
      NSLog(@"You follow eachother!");
    } else if (followed_by == 1) {
      statusLabel.text = [NSString stringWithFormat:@"%@ follows you", self.username];
      NSLog(@"%@ follows you!", self.username);
    } else if (followed_by == 0) {
      statusLabel.text = [NSString stringWithFormat:@"%@ does not follow you", self.username];
      NSLog(@"%@ does not follow you", self.username);
    }
    [userView.headerView addSubview:statusLabel];
  }

  %orig;
}
%end


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
    }
  }
  %orig;
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

%hook AppDelegate
- (void)applicationDidEnterBackground:(id)arg1 {
  if (enabled && showPercents) {
    [likesDict removeAllObjects];
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
    modded = [[NSMutableArray alloc] init];
    
    updatePrefs();
    CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(), NULL,
      &handleNotification,
      (CFStringRef)@"com.jake0oo0.noalertloop/prefsChange",
      NULL, CFNotificationSuspensionBehaviorCoalesce);
    %init(instaHooks);
}
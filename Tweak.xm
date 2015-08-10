#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "substrate.h"
#import "IGHeaders.h"

static NSMutableArray *muted = nil;
static NSMutableArray *modded = nil;
static NSMutableDictionary *likesDict = [[NSMutableDictionary alloc] init];

static NSString *instaMute = @"Mute";
static NSString *instaUnmute = @"Unmute";
static NSString *prefsLoc = @"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist";

static void initPrefs() {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] init];
    NSMutableArray *vals = [[NSMutableArray alloc] init];
    [prefs setValue:@YES forKey:@"enabled"];
    [prefs setValue:vals forKey:@"muted_users"];
    [prefs writeToFile:prefsLoc atomically:YES];
}

static void loadPrefs() {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];

    if (!muted) {
        muted = [[NSMutableArray alloc] init];
    }
    if (prefs) {
        [muted removeAllObjects];
        [muted addObjectsFromArray:[prefs objectForKey:@"muted_users"]];
    } else {
        initPrefs();
        loadPrefs();
    }

    [prefs release];
}

%group instaHooks

%hook IGActionSheet

- (void)show {
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

    %orig();
}

%end

%hook IGMainFeedViewController
-(BOOL)shouldHideFeedItem:(IGFeedItem *)item {
    if ([muted containsObject:item.user.username] or [item isHidden]) {
        return YES;
    } else {
        return %orig;
    }
}
%end


%hook IGCollectionViewController
-(void)finishRefreshFromPullToRefreshControl {
    [modded removeAllObjects];
    %orig;
}
%end


%hook IGFeedItemTextCell
-(IGStyledString*)styledStringForLikesWithFeedItem:(IGFeedItem*)item {
    IGStyledString *styled = %orig;
    IGCoreTextView *coreView = self.coreTextView;
    NSLog(@"COUNT %d", (int)[likesDict count]);
    int likeCount = [[likesDict objectForKey:[item getMediaId]] intValue];
    if (likeCount && likeCount == item.likeCount) { 
        NSLog(@"ORIGINAL %@", [[styled attributedString] string]);
        [coreView setNeedsDisplay];
        return styled;
    } else {
        NSLog(@"IG WILL REWRITE STRING %@", [[styled attributedString]string]);

        [likesDict setObject:[NSNumber numberWithInt:item.likeCount] forKey:[item getMediaId]];
        if (item.user.followerCount) {

            int followers = [item.user.followerCount intValue];
            float percent = ((float)item.likeCount / (float)followers) * 100.0;
            NSString *display = [NSString stringWithFormat:@" - %.01f%%", percent];
            NSMutableAttributedString *original = [[NSMutableAttributedString alloc] initWithAttributedString:[styled attributedString]];
            NSMutableDictionary *attributes = [[original attributesAtIndex:0 effectiveRange:NULL] mutableCopy];
            [attributes setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
            NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:display attributes:attributes];
            [original appendAttributedString:formatted];
            coreView.styledString.attributedString = original;
            [coreView setNeedsDisplay]; 
            NSLog(@"We have %@", original);
        } else {
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [item.user fetchAdditionalUserDataWithCompletion:^(BOOL finished) {
                    int followers = [item.user.followerCount intValue];
                    float percent = ((float)item.likeCount / (float)followers) * 100.0;
                    NSString *display = [NSString stringWithFormat:@" - %.01f%%", percent];
                    NSMutableAttributedString *original = [[NSMutableAttributedString alloc] initWithAttributedString:[styled attributedString]];
                    NSMutableDictionary *attributes = [[original attributesAtIndex:0 effectiveRange:NULL] mutableCopy];
                    [attributes setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
                    NSMutableAttributedString *formatted = [[NSMutableAttributedString alloc] initWithString:display attributes:attributes];
                    [original appendAttributedString:formatted];
                    coreView.styledString.attributedString = original;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [coreView setNeedsDisplay];  
                    });
                    NSLog(@"We have %@", original);
                }];
            });
    
        }
    }
    return styled;
}
%end


%hook IGUserDetailViewController
-(void)actionSheetDismissedWithButtonTitled:(NSString *)title {
    if ([title isEqualToString:instaMute]) {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
        NSMutableArray *keys = [prefs objectForKey:@"muted_users"];
        [keys addObject:self.user.username];
        [prefs setValue:keys forKey:@"muted_users"];
        [prefs writeToFile:prefsLoc atomically:YES];
        loadPrefs();
    } else if ([title isEqualToString:instaUnmute]) {
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
        NSMutableArray *keys = [prefs objectForKey:@"muted_users"];
        [keys removeObject:self.user.username];
        [prefs setValue:keys forKey:@"muted_users"];
        [prefs writeToFile:prefsLoc atomically:YES];
        loadPrefs();
    } else {
        %orig;
    }
}
%end

/*
    Hide sponsored posts
*/

%hook IGFeedItemTimelineLayoutAttributes
-(BOOL)sponsoredContext {
    return false;
}
%end

%hook IGFeedItemHeader
-(BOOL)sponsoredPostAllowed {
    return false;
}
%end

%hook IGFeedItemActionCell
-(BOOL)sponsoredPostAllowed {
    return false;
}
%end

%hook IGSponsoredPostInfo
-(BOOL)showIcon {
    return false;
}
-(BOOL)hideCommentButton {
    return true;
}
-(BOOL)isHoldout {
    return true;
}
-(BOOL)hideComments {
    return true;
}
%end

%end

%ctor {
    modded = [[NSMutableArray alloc] init];
    loadPrefs();
    %init(instaHooks);
}
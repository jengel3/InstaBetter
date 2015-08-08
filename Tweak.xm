#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "substrate.h"
#import "IGHeaders.h"

static NSMutableArray *muted = nil;
static NSMutableArray *modded = nil;

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

%hook IGUser
+(void)fetchFollowStatusInBulk:(id)fp8 {
	%orig;
}
-(void)fetchAdditionalUserDataWithCompletion:(id)fp8 {
	%orig;
}
-(void)fetchFollowStatus {
	%orig;
}
%end

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

%hook IGFeedViewController
-(void)handleDidDisplayFeedItem:(IGFeedItem *)item {
	// NSLog(@"CAlling!! --- %@", item.user.username);
}
%end

%hook IGFeedItemTextCell
-(IGStyledString*)styledStringForLikesWithFeedItem:(IGFeedItem*)item {
	IGStyledString *styled = %orig;
	if (![modded containsObject:[item getMediaId]]) {
		if (item.user.followerCount) {
			int followers = [item.user.followerCount intValue];
			float percent = ((float)item.likeCount / (float)followers) * 100.0;
			NSString *display = [NSString stringWithFormat:@"     %.02f%%", percent];
			[styled appendString:display];
			[modded addObject:[item getMediaId]];
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

%end

%ctor {
	modded = [[NSMutableArray alloc] init];
	loadPrefs();
	%init(instaHooks);
}
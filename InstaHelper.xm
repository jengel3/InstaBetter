#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "InstaHelper.h"
#import "IGHeaders.h"
#import "substrate.h"

@implementation InstaHelper
+ (IGRootViewController *)rootViewController {
  AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
  return (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
}

+ (UIViewController *)currentController {
  IGRootViewController *rootController = [InstaHelper rootViewController];
  return rootController.topMostViewController;
}

+ (IGUser *)currentUser {
  IGAuthHelper *authHelper = [%c(IGAuthHelper) sharedAuthHelper];
  if ([authHelper respondsToSelector:@selector(currentUser)]) {
    return authHelper.currentUser;
  }
  return [%c(IGAuthHelper) currentUser];
}

+ (NSDate *)takenAt:(IGFeedItem*)feedItem {
  BOOL responds = [feedItem respondsToSelector:@selector(takenAt)];
  if (responds) {
    return [feedItem takenAt];
  } else {
    return [feedItem albumAwareTakenAtDate];
  }

}
@end
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

+ (NSDate *)takenAt:(IGPost*)post {
  IGFeedItem *feedItem = (IGFeedItem*)post;
  BOOL responds = [feedItem respondsToSelector:@selector(takenAt)];
  if (responds) {
    return [feedItem takenAt].date;
  } else {
    return [feedItem albumAwareTakenAtDate].date;
  }

}
@end
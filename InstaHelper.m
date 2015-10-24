#import "InstaHelper.h"
#import "IGHeaders.h"

@implementation InstaHelper
+ (IGRootViewController*) rootViewController {
  AppDelegate *igDelegate = [UIApplication sharedApplication].delegate;
  return (IGRootViewController *)((IGShakeWindow *)igDelegate.window).rootViewController;
}

+ (UIViewController*) currentController {
  IGRootViewController *rootController = [InstaHelper rootViewController];
  return rootController.topMostViewController;
}

+ (IGUser*) currentUser {
  return ((IGAuthHelper*)[%c(IGAuthHelper) sharedAuthHelper]).currentUser;
}
@end
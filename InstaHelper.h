#import "IGHeaders.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface InstaHelper : NSObject
+ (IGRootViewController *)rootViewController;
+ (UIViewController *)currentController;
+ (IGUser *)currentUser;
+ (NSDate *)takenAt:(IGFeedItem*)feedItem;
@end
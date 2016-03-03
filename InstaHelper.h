#import "IGHeaders.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface InstaHelper : NSObject
+ (IGRootViewController *)rootViewController;
+ (UIViewController *)currentController;
+ (IGUser *)currentUser;
+ (NSDate *)takenAt:(IGPost*)feedItem;
+ (void)saveVideoToAlbum:(NSURL*)localUrl album:(NSString*)album completion:(void (^)(NSError *error))completion;
+ (void)downloadRemoteFile:(NSURL*)url completion:(void (^)(NSData *data, NSError *complErr))completion;


+ (void)saveRemoteVideo:(NSURL*)url completion:(void (^)(NSError *error))completion;
+ (void)saveRemoteImage:(NSURL*)url completion:(void (^)(NSError *error))completion;
@end
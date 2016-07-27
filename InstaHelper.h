#import "IGHeaders.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface InstaHelper : NSObject
+ (IGRootViewController *)rootViewController;
+ (UIViewController *)currentController;
+ (IGUser *)currentUser;
+ (IGUserSession *)currentSession;

+ (BOOL)isJailbroken;

+ (NSURL*)documentsDirectory;

+ (NSDate *)takenAt:(IGPost*)feedItem;
+ (void)saveVideoToAlbum:(NSURL*)localUrl album:(NSString*)album completion:(void (^)(NSError *error))completion;
+ (void)downloadRemoteFile:(NSURL*)url completion:(void (^)(NSData *data, NSError *complErr))completion;

+ (void)saveRemoteVideo:(NSURL*)url album:(NSString*)album completion:(void (^)(NSError *error))completion;
+ (void)saveRemoteImage:(NSURL*)url album:(NSString*)album completion:(void (^)(NSError *error))completion;

+ (BOOL)isRemoteImage:(NSURL*)url;

+ (void)addImage:(UIImage*)image toCollection:(id)collection completion:(void (^)(NSError *error))completion;
+ (void)addVideo:(NSURL*)videoURL toCollection:(id)collection completion:(void (^)(NSError *error))completion;
@end
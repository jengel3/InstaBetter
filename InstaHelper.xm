#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
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
  } else if ([feedItem respondsToSelector:@selector(takenAtDate)]) {
    // instagram 7.19
    return [feedItem takenAtDate].date;
  } else {
    return [feedItem albumAwareTakenAtDate].date;
  }

}

+ (void)saveVideoToAlbum:(NSURL*)localUrl album:(NSString*)album completion:(void (^)(NSError *error))completion {
  ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

  [library writeVideoAtPathToSavedPhotosAlbum:localUrl
    completionBlock:^(NSURL *assetURL, NSError *error){
      if (error) {
        completion(error);
      } else {
        if (album) {
          [InstaHelper setupPhotoAlbumNamed:album withCompletionHandler:^(ALAssetsLibrary *assetsLibrary, ALAssetsGroup *group) {
            [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
              [group addAsset:asset];
              completion(nil);
            } failureBlock:^(NSError *error) {
              completion(error);
            }];
          }];
        } else {
          completion(nil);
        }
      }
    }];

}

+ (void)downloadRemoteFile:(NSURL*)url completion:(void (^)(NSData *data, NSError *complErr))completion {
  NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:7.5];
  [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue]
    completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
      if (error) {
        completion(nil, error);
      } else {
        completion(data, nil);
      }
    }];
}

+ (void)saveRemoteVideo:(NSURL*)url album:(NSString*)album completion:(void (^)(NSError *error))completion {
  [InstaHelper downloadRemoteFile:url completion:^(NSData *vidData, NSError *viderr) {
    if (viderr) return completion(viderr);
    NSFileManager *fsmanager = [NSFileManager defaultManager];
    NSURL *videoDocs = [[fsmanager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    NSURL *saveUrl = [videoDocs URLByAppendingPathComponent:[url lastPathComponent]];

    dispatch_async(dispatch_get_main_queue(), ^{
      [vidData writeToURL:saveUrl atomically:YES];
      if (album) {
        [InstaHelper saveVideoToAlbum:saveUrl album:album completion: ^(NSError *saveErr) {
          if (saveErr) {
            completion(saveErr);
          } else {
            // we don't want to remove this due to needing it for the share sheet
            // [fsmanager removeItemAtPath:[saveUrl path] error:NULL];
            completion(nil);
          }
        }];
      } else {
        completion(nil);
      }
    });
  }];
}

+ (void)saveRemoteImage:(NSURL*)url album:(NSString*)album completion:(void (^)(NSError *error))completion {
  NSData *imgData = [NSData dataWithContentsOfURL:url];

  [InstaHelper setupPhotoAlbumNamed:album withCompletionHandler:^(ALAssetsLibrary *assetsLibrary, ALAssetsGroup *group) {
    [InstaHelper addImage:[UIImage imageWithData:imgData] toAssetsLibrary:assetsLibrary withGroup:group completion: ^(NSError *saveErr) {
      completion(saveErr);
    }];
  }];

}

+ (BOOL)isRemoteImage:(NSURL*)url {
  NSArray *extensions = @[@"jpg", @"jpeg", @"png"];

  NSString *ext = [url pathExtension];

  return [extensions containsObject:[ext lowercaseString]];
}

+ (void)setupPhotoAlbumNamed:(NSString*)photoAlbumName withCompletionHandler:(void(^)(ALAssetsLibrary*, ALAssetsGroup*))completion {
  ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
  __weak ALAssetsLibrary *weakAssetsLibrary = assetsLibrary;
  [assetsLibrary addAssetsGroupAlbumWithName:photoAlbumName resultBlock:^(ALAssetsGroup *group) {
    if (!group) {
      [weakAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAlbum usingBlock:^(ALAssetsGroup *g, BOOL *stop) {
        if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:photoAlbumName]) {
          completion(weakAssetsLibrary, g);
        }
      } failureBlock:^(NSError *error) {
        completion(weakAssetsLibrary, nil);
      }];
    } else {
      completion(weakAssetsLibrary, group);
    }
  } failureBlock:^(NSError *error) {
    completion(weakAssetsLibrary, nil);
  }];
}

+ (void)addImage:(UIImage*)image toAssetsLibrary:(ALAssetsLibrary*)assetsLibrary withGroup:(ALAssetsGroup*)group completion:(void (^)(NSError *error))completion {
  [assetsLibrary writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(image) metadata:nil completionBlock:
   ^(NSURL *assetURL, NSError *error) {
     if (error) {
      completion(error);
    } else {
      [assetsLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        [group addAsset:asset];
        completion(nil);
      } failureBlock:^(NSError *error) {
        completion(error);
      }];
    }
  }];
}

@end
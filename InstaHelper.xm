#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "InstaHelper.h"
#import "IGHeaders.h"
#import "substrate.h"

@class PHAssetCollection;

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

+ (IGUserSession *)currentSession {
  IGAuthHelper *authHelper = [%c(IGAuthHelper) sharedAuthHelper];
  return [authHelper currentUserSession];
}

+ (BOOL)isJailbroken {
  NSString *aptitudeFolder = @"/etc/apt";
  BOOL dir = NO;
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:aptitudeFolder isDirectory:&dir];

  if (exists) {
    return YES;
  } else {
    return NO;
  }
}

+ (NSURL*)documentsDirectory {
  return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
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
  Class PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");

  if (PHPhotoLibrary_class) {
    PHAssetCollection *existingCollection;

    if (album) {
      PHFetchOptions *albumsFetchOption = [[PHFetchOptions alloc] init];
      albumsFetchOption.predicate = [NSPredicate predicateWithFormat:@"title == %@",album];

      PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:albumsFetchOption];
      existingCollection = userAlbums.firstObject;
    }

    if (!existingCollection && album) {
      __block PHObjectPlaceholder *albumPlaceholder;
      [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:album];
        albumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;
      } completionHandler:^(BOOL success, NSError *error) {
        if (success) {
          PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumPlaceholder.localIdentifier] options:nil];
          PHAssetCollection *assetCollection = fetchResult.firstObject;
          [InstaHelper addVideo:localUrl toCollection:assetCollection completion:^(NSError *error) {
            completion(error);
          }];

        } else {
        // NSLog(@"Error creating album: %@", error);
          completion(error);
        }
      }];
    } else {
      [InstaHelper addVideo:localUrl toCollection:existingCollection completion:^(NSError *error) {
       completion(error);
     }];
    }
  } else {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];

    [library writeVideoAtPathToSavedPhotosAlbum:localUrl
      completionBlock:^(NSURL *assetURL, NSError *error){
        if (error) {
          completion(error);
        } else {
          completion(nil);
        }
      }];

  }

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
  Class PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");

  if (PHPhotoLibrary_class) {
    [InstaHelper downloadRemoteFile:url completion:^(NSData *vidData, NSError *viderr) {
      if (viderr) return completion(viderr);
      NSFileManager *fsmanager = [NSFileManager defaultManager];
      NSURL *videoDocs = [[fsmanager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
      NSURL *saveUrl = [videoDocs URLByAppendingPathComponent:[url lastPathComponent]];

      dispatch_async(dispatch_get_main_queue(), ^{
        [vidData writeToURL:saveUrl atomically:YES];
        [InstaHelper saveVideoToAlbum:saveUrl album:album completion: ^(NSError *saveErr) {
          if (saveErr) {
            completion(saveErr);
          } else {
            // we don't want to remove this due to needing it for the share sheet
            // [fsmanager removeItemAtPath:[saveUrl path] error:NULL];
            completion(nil);
          }
        }];
      });
    }];
  } else {
    [InstaHelper downloadRemoteFile:url completion:^(NSData *vidData, NSError *viderr) {
      if (viderr) return completion(viderr);
      NSFileManager *fsmanager = [NSFileManager defaultManager];
      NSURL *videoDocs = [[fsmanager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
      NSURL *saveUrl = [videoDocs URLByAppendingPathComponent:[url lastPathComponent]];

      dispatch_async(dispatch_get_main_queue(), ^{
        [vidData writeToURL:saveUrl atomically:YES];
        [InstaHelper saveVideoToAlbum:saveUrl album:@"InstaBetter" completion: ^(NSError *saveErr) {
          if (saveErr) {
            completion(saveErr);
          } else {
            completion(nil);
          }
        }];
      });


    }];
  }
}

+ (void)saveRemoteImage:(NSURL*)url album:(NSString*)album completion:(void (^)(NSError *error))completion {
  Class PHPhotoLibrary_class = NSClassFromString(@"PHPhotoLibrary");
  NSLog(@"SAVING REMOTE IMAGE!!");
  if (PHPhotoLibrary_class) {
    [InstaHelper downloadRemoteFile:url completion:^(NSData *imgData, NSError *imgerr) {
      UIImage *image = [UIImage imageWithData:imgData];

      PHAssetCollection *existingCollection;

      if (album) {
        PHFetchOptions *albumsFetchOption = [[PHFetchOptions alloc] init];
        albumsFetchOption.predicate = [NSPredicate predicateWithFormat:@"title == %@",album];

        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:albumsFetchOption];
        existingCollection = userAlbums.firstObject;
      }

      // Photos framework does not handle existing collections, so we have to do that ourselves
      if (!existingCollection && album) {
        __block PHObjectPlaceholder *albumPlaceholder;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
          PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:album];
          albumPlaceholder = changeRequest.placeholderForCreatedAssetCollection;
        } completionHandler:^(BOOL success, NSError *error) {
          if (success) {
            PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[albumPlaceholder.localIdentifier] options:nil];
            PHAssetCollection *assetCollection = fetchResult.firstObject;
            [InstaHelper addImage:image toCollection:assetCollection completion:^(NSError *error) {
              completion(error);
            }];

          } else {
            completion(error);
          }
        }];
      } else {
        [InstaHelper addImage:image toCollection:existingCollection completion:^(NSError *error) {
          completion(error);
        }];
      }
    }];
  } else {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSData *imgData = [NSData dataWithContentsOfURL:url];
    NSLog(@"CALLED SAVING!!");
    [library writeImageDataToSavedPhotosAlbum:imgData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
      NSLog(@"CHECKING %@", error);
      if (error) {
        NSLog(@"COMPLETED WITH ERROR!!");
        completion(error);
      } else {
        NSLog(@"COMPLETED WITH NO ERROR!!");
        completion(nil);
      }
    }];
  }

}

+ (BOOL)isRemoteImage:(NSURL*)url {
  NSArray *extensions = @[@"jpg", @"jpeg", @"png"];

  NSString *ext = [url pathExtension];

  return [extensions containsObject:[ext lowercaseString]];
}


+ (void)addImage:(UIImage*)image toCollection:(id)collection completion:(void (^)(NSError *error))completion {
  [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];

    if (collection) {
      PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
      [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    }
  } completionHandler:^(BOOL success, NSError *error) {
    if (!success) {
      // NSLog(@"Error creating asset: %@", error);
    }
    completion(error);
  }];
}

+ (void)addVideo:(NSURL*)videoURL toCollection:(id)collection completion:(void (^)(NSError *error))completion {
  [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
    PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
    NSLog(@"Successfully saved!");
    if (collection) {
      PHAssetCollectionChangeRequest *assetCollectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
      [assetCollectionChangeRequest addAssets:@[[assetChangeRequest placeholderForCreatedAsset]]];
    }
  } completionHandler:^(BOOL success, NSError *error) {
    if (!success) {
      // NSLog(@"Error creating asset: %@", error);
    }
    completion(error);
  }];
}

@end
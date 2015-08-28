#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface IGUser : NSObject
@property (strong, nonatomic) NSString *username;
+(void)fetchFollowStatusInBulk:(NSArray*)users;
-(id)followingCount;
-(id)followerCount;
-(void)fetchAdditionalUserDataWithCompletion:(id)fp8;
-(id)initWithDictionary:(id)data;
-(void)onFriendStatusReceived:(NSDictionary*)status fromRequest:(id)req;
-(id)secondaryName;
-(id)primaryName;
-(id)fullOrDisplayName;
-(id)toDict;
@end

@interface IGSpringButton : UIControl
@end

@interface IGFollowButton : IGSpringButton
@end

@interface IGStyledString
@property(retain, nonatomic) NSMutableAttributedString *attributedString;
-(void)appendString:(id)str;
-(void)appendAttributedString:(id)styled;
@end

@interface IGViewController : UIViewController
@end

@interface IGCoreTextView : UIView
@property(retain, nonatomic) IGStyledString *styledString;
@end

@interface IGUserDetailHeaderView : UIView
@property(retain, nonatomic) IGFollowButton *followButton;
@property(retain, nonatomic) IGCoreTextView *infoLabelView;
@end

@interface IGPhoto
-(NSDictionary*)imageVersions;
@end

@interface IGVideo
-(NSDictionary*)videoVersions;
@end

@interface IGPost : NSObject

@property (strong, nonatomic) IGUser *user;
@property(readonly) int mediaType;
@property (strong, nonatomic) IGVideo *video;
@property (strong, nonatomic) IGPhoto *photo;
-(id)init;
-(id)initWithCoder:(id)fp8;
-(int)likeCount;
-(id)imageURLForFullSizeImage;
@end

@interface IGFeedItem : IGPost
+(int)fullSizeImageVersionForDevice;
- (id)imageURLForImageVersion:(int)arg1;
-(id)description;
-(BOOL)isHidden;
-(id)getMediaId;
-(void)setIsHidden:(BOOL)hidden;
-(id)initWithCoder:(id)fp8;
-(id)init;
@end

@interface IGAssetWriter

@property (nonatomic,retain) UIImage *image;
+ (void)writeVideo:(id)arg1 toInstagramAlbum:(BOOL)arg2 completionBlock:(id)arg3;
+ (void)writeVideoToCameraRoll:(id)arg1;
+ (void)writeVideoToInstagramAlbum:(id)arg1 completionBlock:(id)arg2;
- (id)initWithImage:(id)arg1 metadata:(id)arg2;
- (void)writeToInstagramAlbum;
- (id)init;

@end

@interface IGFeedItemActionCell
@property(retain, nonatomic) IGFeedItem *feedItem;
-(BOOL)sponsoredPostAllowed;
-(id)initWithFrame:(CGRect)frame;
-(UIButton*)likeButton;
-(void)actionSheetDismissedWithButtonTitled:(NSString *)title;
@end

@interface AppDelegate : NSObject
- (void)startMainAppWithMainFeedSource:(id)source animated:(BOOL)animated;
- (void)applicationDidEnterBackground:(id)arg1;
- (id)window; 
@end

@interface IGMainFeedViewController
-(BOOL)shouldHideFeedItem:(id)fp8;
-(BOOL)isFirstFeedLoad;
-(void)setIsFirstFeedLoad:(BOOL)first;
@end

@interface IGCollectionViewController
-(void)onPullToRefresh:(id)fp8;
-(void)finishRefreshFromPullToRefreshControl;
@end

@interface IGFeedViewController
-(void)handleDidDisplayFeedItem:(IGFeedItem*)item;
-(id)arrayOfCellsWithClass:(Class)clazz inSection:(int)sec;
@end

@interface IGUserDetailViewController : IGViewController
-(void)actionSheetDismissedWithButtonTitled:(NSString *)title;
-(IGUser *)user;
@property(retain, nonatomic) IGUserDetailHeaderView *headerView;
@end

@interface IGRootViewController : UIViewController
-(id)topMostViewController;
@end

@interface IGSimpleTableViewCell : UITableViewCell
@end

@interface IGFeedItemTextCell : IGSimpleTableViewCell
-(IGStyledString*)styledStringForLikesWithFeedItem:(IGFeedItem*)item;
@property(retain, nonatomic) IGFeedItem *feedItem;
@property(retain, nonatomic) IGCoreTextView *coreTextView;
@property(weak, nonatomic) UINavigationController *navigationController; 
-(void)layoutSubviews;
-(int)accessibilityElementCount;
-(id)accessibilityElementAtIndex:(int)index;
-(id)accessibleElements;
@end

@interface IGShakeWindow : UIWindow
- (id)rootViewController;
@end

@interface IGActionSheet
- (void)addButtonWithTitle:(NSString *)title style:(int)style;
@end

@interface IGFeedItemHeader
-(BOOL)sponsoredPostAllowed;
@end

@interface IGFeedItemTimelineLayoutAttributes
-(BOOL)sponsoredContext;
@end

@interface IGSponsoredPostInfo
-(BOOL)showIcon;
-(BOOL)hideCommentButton;
-(BOOL)isHoldout;
-(BOOL)hideComments;
@end

@interface IGCollectionView : UICollectionView
@end

@interface IGCollectionViewCell : UICollectionViewCell
@end

@interface IGInternalCollectionView
-(id)visibleIndexPaths;
@end

@interface IGCustomLocationDataSource : NSObject
-(id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
-(id)tableView:(id)arg1 customLocationCellForRowAtIndexPath:(id)arg2;
@end

@interface IGRequest
@end

@interface IGStorableObject : NSObject
-(id)initWithDictionary:(id)arg1 ;
@end
@interface IGLocation : IGStorableObject
-(id)initWithDictionary:(id)arg1 ;
@end

@interface IGLocationDataSource : NSObject <UITableViewDataSource> 
-(id)tableView:(id)arg1 errorCellForRowAtIndexPath:(id)arg2 ;
-(id)tableView:(id)arg1 statusCellForRowAtIndexPath:(id)arg2 ;
-(id)tableView:(id)arg1 attributionCellForRowAtIndexPath:(id)arg2 ;
-(id)tableView:(id)arg1 locationCellForRowAtIndexPath:(id)arg2 ;

-(void)reloadData;
-(int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2 ;
-(id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 ;
-(int)numberOfSectionsInTableView:(id)arg1 ;
-(BOOL)isLoading;
-(void)setIsLoading:(BOOL)arg1 ;
-(NSArray *)locations;
@property (nonatomic,retain) NSString * responseQueryText;  
@end
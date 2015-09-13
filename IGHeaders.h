#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <lib/Protocols/NYTPhoto.h>

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

@interface InstaBetterPhoto : NSObject <NYTPhoto>
@property (nonatomic) UIImage *image;
@property (nonatomic) UIImage *placeholderImage;
@property (nonatomic) NSAttributedString *attributedCaptionTitle;
@property (nonatomic) NSAttributedString *attributedCaptionSummary;
@property (nonatomic) NSAttributedString *attributedCaptionCredit;
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


@protocol IGCoreTextLinkHandler <NSObject>
-(void)coreTextView:(id)arg1 didLongTapOnString:(id)arg2 URL:(id)arg3;
-(void)coreTextView:(id)arg1 didTapOnString:(id)arg2 URL:(id)arg3;
@end


@interface IGCoreTextView : UIView <IGCoreTextLinkHandler, UIWebViewDelegate, UILongPressGestureRecognizerDelegate>
@property(retain, nonatomic) IGStyledString *styledString;
@property (assign,nonatomic) id<IGCoreTextLinkHandler> linkHandler;
-(void)setLinkHandler:(id<IGCoreTextLinkHandler>)arg1 ;
-(void)setStyledString:(IGStyledString *)arg1 ;
-(long)findClosestIndexForURLForAttributedString:(id)arg1 nearPoint:(CGPoint)arg2 constrainedSize:(CGSize)arg3 ;
@end

@interface IGUserDetailHeaderView : UIView
@property(retain, nonatomic) IGFollowButton *followButton;
@property(retain, nonatomic) IGCoreTextView *infoLabelView;
-(void)coreTextView:(id)arg1 didTapOnString:(id)arg2 URL:(id)arg3 ;
@end

@interface IGPhoto
-(NSDictionary*)imageVersions;
@end

@interface IGVideo
-(NSDictionary*)videoVersions;
@end

@interface IGCommentModel : NSObject
@property (nonatomic,copy) NSString * text;
@end

@interface IGDate : NSObject <NSCoding> 

@property (nonatomic,readonly) long long microseconds;                   //@synthesize microseconds=_microseconds - In the implementation block
@property (nonatomic,copy,readonly) NSString * stringValue; 
-(id)initWithMicroseconds:(long long)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(void)encodeWithCoder:(id)arg1 ;
-(id)description;
-(int)compare:(id)arg1 ;
-(id)date;
-(double)timeIntervalSinceNow;
-(id)initWithString:(id)arg1 ;
-(double)timeIntervalSince1970;
-(id)initWithObject:(id)arg1 ;
-(id)initWithTimeInterval:(double)arg1 ;
@end

@interface IGPost : NSObject
@property (strong, nonatomic) IGUser *user;
@property(readonly) int mediaType;
@property (strong, nonatomic) IGVideo *video;
@property (strong, nonatomic) IGPhoto *photo;
@property (readonly) IGCommentModel * caption;
@property (readonly) BOOL hasLiked;
@property (readonly) IGDate * takenAt;
-(id)init;
-(id)initWithCoder:(id)fp8;
-(int)likeCount;
-(id)imageURLForFullSizeImage;
@end

@interface IGFeedItem : IGPost
@property (readonly) IGDate * takenAt; 
+(int)fullSizeImageVersionForDevice;
- (id)imageURLForImageVersion:(int)arg1;
-(id)description;
-(BOOL)isHidden;
-(id)getMediaId;
-(void)setIsHidden:(BOOL)hidden;
-(id)initWithCoder:(id)fp8;
-(id)init;
-(NSString *)permalink;
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
-(UINavigationController*)window;
@end

@interface AppDelegate : NSObject
- (void)startMainAppWithMainFeedSource:(id)source animated:(BOOL)animated;
- (void)applicationDidEnterBackground:(id)arg1;
- (id)window;
-(id)navigationController;
-(BOOL)application:(id)arg1 handleOpenURL:(id)arg2 ;
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
-(void)setFeedLayout:(int)arg1 ;
-(int)feedLayout;
-(id)initWithFeedNetworkSource:(id)arg1 feedLayout:(int)arg2 showsPullToRefresh:(char)arg3 ;
-(void)startVideoForCellMovingOnScreen;
-(id)videoCellForAutoPlay;
-(BOOL)isDeviceSupportAlwaysAutoPlay;
@end

@interface IGMediaCaptureViewController
-(BOOL)shouldAutoPlayVideo;
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

@protocol IGFeedHeaderItem <NSObject>
@property (readonly) IGDate * takenAt; 
@end

@interface IGFeedItemHeader : UIView
@property (nonatomic,retain) UIButton * timestampButton;
-(BOOL)sponsoredPostAllowed;
@property (nonatomic,retain) id<IGFeedHeaderItem> feedItem;
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
-(id)name;
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

@interface IGURLHelper : NSObject
+(void)openExternalURL:(id)arg1 controller:(id)arg2 modal:(char)arg3 controls:(char)arg4 completionHandler:(/*^block*/id)arg5 ;
@end

@interface IGImageView : UIImageView
@end

@interface IGImageProgressView : UIView
@property (nonatomic,readonly) IGImageView * photoImageView;
@end

@interface IGFeedMediaView : UIView <UIGestureRecognizerDelegate, UILongPressGestureRecognizerDelegate, NYTPhotosViewControllerDelegate>
@property (nonatomic,retain) IGPost * post;
@property (nonatomic,readonly) IGImageProgressView * photoImageView; 
@end

@interface IGDirectedPost
-(void)performRead;
-(BOOL)isRead;
-(void)setIsRead:(BOOL)read;
@end

@interface IGDirectedPostRecipient
-(BOOL)hasRead;
-(void)setHasRead:(BOOL)arg1 ;
@end

@interface IGFeedItemPhotoCell
@property (nonatomic,retain) IGPost * post;
@end

@interface IGProfilePictureImageView : IGImageView <UIGestureRecognizerDelegate, UILongPressGestureRecognizerDelegate>
@property (nonatomic,readonly) UIImage * originalImage;
@property (nonatomic,retain) IGUser * user;  
-(id)initWithFrame:(CGRect)arg1;
-(id)initWithFrame:(CGRect)arg1 user:(id)arg2 ;
-(void)tapped:(id)arg1 ;
@property (assign,nonatomic) BOOL buttonDisabled;
-(void)setButtonDisabled:(BOOL)arg1 ;
-(BOOL)buttonDisabled;
@end

@interface IGFeedToggleView : UIView
+(id)feedToggleViewForUserHeader;
+(id)feedToggleViewForProfileHeader;
@end

@interface Appirater : NSObject
-(void)showRatingAlert;
@end

@interface IGFeedNetworkSource
+(id)feedWithLatest;
@end

@interface IGMainFeedNetworkSource
@end

@interface IGUsertagGroup
@property (assign,nonatomic) IGFeedItem * feedItem;  
@end

@interface IGFeedPhotoView
@property (nonatomic,retain) IGUsertagGroup * usertags; 
-(void)onDoubleTap:(id)arg1 ;
@property (assign,nonatomic) IGFeedItemPhotoCell * parentCellView;
@end

@interface IGFeedItemVideoView
-(void)onDoubleTap:(id)arg1 ;
@property (nonatomic,readonly) IGPost * post;
@end

@interface SBMediaController
+(id)sharedInstance;
-(BOOL)isRingerMuted;
@end

@interface IGVideoPlayer : NSObject
@property (assign,nonatomic) BOOL muted;
-(BOOL)isMuted;
-(void)setMuted:(BOOL)arg1 ;
-(void)playFromStart;
-(void)stop;
@end

@interface IGFeedVideoPlayer : NSObject
@property (assign,nonatomic) BOOL audioEnabled;
-(BOOL)isAudioEnabled;
-(void)setAudioEnabled:(BOOL)arg1 ;
-(void)setReadyToPlay:(char)arg1 ;
-(void)play;
-(id)player;
@end

@interface IGFeedItemVideoCell
@property (nonatomic,retain) IGFeedItemVideoView * videoView; 

@end

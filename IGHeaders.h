#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "lib/Protocols/NYTPhoto.h"
#import "lib/NYTPhotoViewController.h"
#import "lib/NYTPhotosViewController.h"
#import <MapKit/MapKit.h>

@interface IGUser : NSObject
@property (strong, nonatomic) NSString *username;
@property (retain) NSURL *profilePicURL;
@property (assign) int followStatus;
@property (assign) int lastFollowStatus;
@property (retain) NSArray * HDProfilePicVersions;
- (id)HDProfilePicURL;
+ (void)fetchFollowStatusInBulk:(NSArray*)users;
- (id)followingCount;
- (id)followerCount;
- (BOOL)isVerified;
- (void)fetchAdditionalUserDataWithCompletion:(id)fp8;
- (id)initWithDictionary:(id)data;
- (void)onFriendStatusReceived:(NSDictionary*)status fromRequest:(id)req;
- (id)secondaryName;
- (id)primaryName;
- (id)fullOrDisplayName;
- (id)toDict;
@end

@interface IGUserSession : NSObject
@property (nonatomic,retain) IGUser * user;
@end

@interface IGNewsInboxTableViewController
-(void)unreadCountUpdated:(id)arg1 ;
-(void)onDataReceived:(id)arg1 ;
@end

@interface IGPassthroughLabel : UILabel
@end


@interface IGUnreadBubbleView
@property (nonatomic,retain) IGPassthroughLabel * label;
-(void)setUnreadCount:(int)arg1 ;

@end

@interface IGNewsDataSourceSection
@property (nonatomic,copy) NSOrderedSet * stories;
@end

@interface IGAuthHelper : NSObject
@property (nonatomic, retain) IGUser *currentUser;
@property (nonatomic,retain) IGUserSession *currentUserSession;
+ (id)sharedAuthHelper;
- (void)logInWithAuthenticatedUser:(id)arg1;
- (void)switchToAuthenticatedUser:(id)arg1 failureBlock:(id)arg2;
- (void)logInWithAuthenticatedUser:(id)arg1 isSwitchingUsers:(BOOL)arg2;
- (void)switchToAuthenticatedUserWithForce:(id)arg1 fromLogin:(BOOL)arg2;
- (void)clearCurrentUser;
- (void)setCurrentUser:(IGUser *)arg1;
- (void)updateCurrentUser:(id)arg1;
- (BOOL)hasMultipleAccounts;
- (BOOL)passesMultipleAccountsQE;
- (BOOL)hasMaximumNumberOfAccounts;
@end

@interface IGAuthenticatedUser
@property (copy) NSString *pk;
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
- (void)appendString:(id)str;
- (void)appendAttributedString:(id)styled;

-(void)appendLinkedString:(id)arg1 ;
-(void)appendLinkedTitleString:(id)arg1 ;
-(void)appendLinkedString:(id)arg1 withExternalURLs:(char)arg2 ;
@end

@interface IGViewController : UIViewController
@end

@protocol IGCoreTextLinkHandler <NSObject>
- (void)coreTextView:(id)arg1 didLongTapOnString:(id)arg2 URL:(id)arg3;
- (void)coreTextView:(id)arg1 didTapOnString:(id)arg2 URL:(id)arg3;
@end

@interface IGCommentContentView
-(void)coreTextView:(id)arg1 didTapOnString:(id)arg2 URL:(id)arg3 ;
- (void)coreTextView:(id)arg1 didLongTapOnString:(id)arg2 URL:(id)arg3;
@end

@interface IGCoreTextView : UIView <IGCoreTextLinkHandler, UIWebViewDelegate, UIGestureRecognizerDelegate>
@property(retain, nonatomic) IGStyledString *styledString;
@property (assign,nonatomic) id<IGCoreTextLinkHandler> linkHandler;
- (void)setLinkHandler:(id<IGCoreTextLinkHandler>)arg1;
- (void)setStyledString:(IGStyledString *)arg1;
- (long)findClosestIndexForURLForAttributedString:(id)arg1 nearPoint:(CGPoint)arg2 constrainedSize:(CGSize)arg3;

-(BOOL)handleTapAtPoint:(CGPoint)arg1 forTouchEvent:(unsigned)arg2 ;
-(BOOL)handlePaddedTapAtPoint:(CGPoint)arg1 forTouchEvent:(unsigned)arg2 fromLongTap:(char)arg3 ;
-(void)handleLongTap;
-(BOOL)handleTapAtPoint:(CGPoint)arg1 forTouchEvent:(unsigned)arg2 fromLongTap:(char)arg3 ;
-(BOOL)handleTapAtIndex:(int)arg1 forTouchEvent:(unsigned)arg2 fromLongTap:(char)arg3 ;
-(NSURL*)urlAtPoint:(CGPoint)arg1 ;
-(long)findClosestIndexForURLForAttributedString:(id)arg1 nearPoint:(CGPoint)arg2 constrainedSize:(CGSize)arg3 ;
@end

@interface IGPhoto
- (NSDictionary*)imageVersions;
@end

@interface IGVideo
- (NSDictionary*)videoVersions;
@end

@interface IGCommentModel : NSObject
@property (nonatomic,copy) NSString *text;
// DEPRECATED 8.5.1
-(id)buildStyledStringWithNewline:(char)arg1 width:(CGFloat)arg2 numberOfLines:(int)arg3 truncationToken:(id)arg4 ;
// REPLACED BY 8.5.1
-(id)buildStyledStringWithNewline:(char)arg1 width:(CGFloat)arg2 numberOfLines:(int)arg3 truncationToken:(id)arg4 configuration:(id)arg5 ;
-(id)buildStyledStringWithNewline:(char)arg1 width:(CGFloat)arg2 maximumUntruncatedNumberOfLines:(int)arg3 truncatedToNumberOfLines:(int)arg4;
-(id)styledStringForWidth:(CGFloat)arg1 feedItem:(id)arg2 shouldCollapseCaption:(char)arg3 ;
-(id)buildStyledStringWithNewline:(char)arg1 ;
@end

@interface IGDate : NSObject <NSCoding>
@property (nonatomic,readonly) long long microseconds;
@property (nonatomic,copy,readonly) NSString *stringValue;
- (id)initWithMicroseconds:(long long)arg1;
- (id)initWithCoder:(id)arg1;
- (void)encodeWithCoder:(id)arg1;
- (id)description;
- (int)compare:(id)arg1;
- (id)date;
- (double)timeIntervalSinceNow;
- (id)initWithString:(id)arg1;
- (double)timeIntervalSince1970;
- (id)initWithObject:(id)arg1;
- (id)initWithTimeInterval:(double)arg1;
@end

@interface IGPost : NSObject
@property (strong, nonatomic) IGUser *user;
@property(readonly) int mediaType;
@property (strong, nonatomic) IGVideo *video;
@property (strong, nonatomic) IGPhoto *photo;
@property (readonly) IGCommentModel *caption;
@property (readonly) BOOL hasLiked;
@property (readonly) IGDate *takenAt;
@property (readonly) IGDate * takenAtDate;
- (id)init;
- (id)initWithCoder:(id)fp8;
- (int)likeCount;
- (id)imageURLForFullSizeImage;
@end

@interface IGSponsoredPostInfo
- (BOOL)showIcon;
- (BOOL)hideCommentButton;
- (BOOL)isHoldout;
- (BOOL)hideComments;
@end

@interface IGFeedItem : IGPost
@property (readonly) IGDate *takenAt;
@property (readonly) NSString * mediaId;
@property (readonly) IGSponsoredPostInfo * sponsoredPostInfo;
- (IGDate*)albumAwareTakenAtDate;
+ (int)fullSizeImageVersionForDevice;
- (id)imageURLForImageVersion:(int)arg1;
- (id)description;
- (BOOL)isHidden;
- (id)getMediaId;
- (void)setIsHidden:(BOOL)hidden;
- (id)initWithCoder:(id)fp8;
- (id)init;
- (NSString *)permalink;
@end

@interface IGAssetWriter
@property (nonatomic, retain) UIImage *image;
+ (void)writeVideo:(id)arg1 toInstagramAlbum:(BOOL)arg2 completionBlock:(id)arg3;
+ (void)writeVideoToCameraRoll:(id)arg1;
+ (void)writeVideoToInstagramAlbum:(id)arg1 completionBlock:(id)arg2;
- (id)initWithImage:(id)arg1 metadata:(id)arg2;
- (void)writeToInstagramAlbum;
- (id)init;
@end

@interface IGUFIButtonBarView : UIView
@property (nonatomic,readonly) UIButton * likeButton;
@property (nonatomic,readonly) UIButton * commentButton;
@property (nonatomic,readonly) UIButton * sendButton;
- (UIButton *)saveButton;
- (void)setSaveButton:(UIButton *)value;
- (void)shareItem:(id)sender;
- (void)saveItem:(id)sender;
- (void)saveNow;
- (void)setupSubviews;

@property (nonatomic, retain) IGFeedItem *feedItem;

@end

@interface IGFeedItemActionCell : UICollectionViewCell
@property(retain, nonatomic) IGFeedItem *feedItem;
@property (nonatomic, retain) UIButton *sendButton;
@property (nonatomic, retain) UIButton *commentButton;
@property (nonatomic, retain) UIButton *likeButton;
@property (nonatomic,retain) IGUFIButtonBarView * ufiButtonBarView;
- (BOOL)sponsoredPostAllowed;
- (id)initWithFrame:(CGRect)frame;
- (void)actionSheetDismissedWithButtonTitled:(NSString *)title;
- (UINavigationController*)window;
- (UIButton *)saveButton;
- (void)setSaveButton:(UIButton *)value;
- (void)shareItem:(id)sender;
- (void)saveItem:(id)sender;
- (void)saveNow;
- (void)setUfiButtonBarView:(IGUFIButtonBarView *)arg1 ;
@end

@interface AppDelegate : NSObject
- (void)startMainAppWithMainFeedSource:(id)source animated:(BOOL)animated;
- (void)applicationDidEnterBackground:(id)arg1;
- (id)window;
- (id)navigationController;
- (BOOL)application:(id)arg1 handleOpenURL:(id)arg2;
- (BOOL)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2;
- (void)application:(id)arg1 didReceiveRemoteNotification:(id)arg2 fetchCompletionHandler:(/*^block*/id)arg3;
- (void)application:(id)arg1 didReceiveRemoteNotification:(id)arg2;
- (void)application:(id)arg1 handleActionWithIdentifier:(id)arg2 forRemoteNotification:(id)arg3 completionHandler:(/*^block*/id)arg4;
@end

@interface IGFeedItemPreviewingHandler : NSObject
-(id)initWithController:(id)arg1 ;
@end

@interface IGFeedPreviewingHandler : NSObject
- (id)initWithFeedViewController:(id)arg1;
@end

@interface IGFeedViewController_DEPRECATED : UIViewController
@property (assign,nonatomic) int feedLayout;
// @property (nonatomic,readonly) IGFeedDataSource * feedDataSource;
- (void)handleDidDisplayFeedItem:(IGFeedItem*)item;
- (id)arrayOfCellsWithClass:(Class)clazz inSection:(int)sec;
- (void)setFeedLayout:(int)arg1;
- (int)feedLayout;
- (id)initWithFeedNetworkSource:(id)arg1 feedLayout:(int)arg2 showsPullToRefresh:(BOOL)arg3;
- (void)startVideoForCellMovingOnScreen;
- (id)videoCellForAutoPlay;
- (BOOL)isDeviceSupportAlwaysAutoPlay;
- (void)reloadWithNewObjects:(NSArray*)arg1 ;
- (void)actionSheetDismissedWithButtonTitled:(NSString*)arg1 ;
- (void)feedItemActionCellDidTapMoreButton:(IGFeedItemActionCell*)arg1;
- (void)feedItemActionCellDidTapChervonButton:(id)arg1 ;
- (void)reloadWithNewObjects:(NSArray*)arg1 context:(id)arg2 synchronus:(char)arg3 forceAnimated:(char)arg4 completionBlock:(/*^block*/id)arg5 ;
- (void)reloadWithCurrentObjectsAnimated:(char)arg1 ;
- (NSArray*)getMutedList:(NSArray*)items;
- (void)feedItemHeaderDidTapOnMoreButton:(id)arg1 ;
- (void)setFeedPreviewingDelegate:(IGFeedPreviewingHandler *)arg1 ;
- (NSIndexPath *)currentActionCellIndexPath;

-(BOOL)shouldAutoplayVideos;
-(BOOL)allowAutoPlay;
@end

@interface IGFeedViewController : UIViewController
@property (assign,nonatomic) int feedLayout;
- (void)handleDidDisplayFeedItem:(IGFeedItem*)item;
- (id)arrayOfCellsWithClass:(Class)clazz inSection:(int)sec;
- (void)setFeedLayout:(int)arg1;
- (int)feedLayout;
- (id)initWithFeedNetworkSource:(id)arg1 feedLayout:(int)arg2 showsPullToRefresh:(BOOL)arg3;
- (void)startVideoForCellMovingOnScreen;
- (id)videoCellForAutoPlay;
- (BOOL)isDeviceSupportAlwaysAutoPlay;
- (void)reloadWithNewObjects:(NSArray*)arg1 ;
- (void)actionSheetDismissedWithButtonTitled:(NSString*)arg1 ;
- (void)feedItemActionCellDidTapMoreButton:(IGFeedItemActionCell*)arg1;
- (void)reloadWithNewObjects:(NSArray*)arg1 context:(id)arg2 synchronus:(char)arg3 forceAnimated:(char)arg4 completionBlock:(/*^block*/id)arg5 ;
- (void)reloadWithCurrentObjectsAnimated:(char)arg1;
- (NSArray*)getMutedList:(NSArray*)items;
- (void)setFeedPreviewingDelegate:(IGFeedPreviewingHandler *)arg1 ;
@end

@interface IGFeedMainConfiguration : NSObject
-(BOOL)shouldAutoplayVideos;
@end

@interface IGMainFeedViewController : IGFeedViewController
- (BOOL)shouldHideFeedItem:(id)fp8;
- (BOOL)isFirstFeedLoad;
- (void)setIsFirstFeedLoad:(BOOL)first;
-(NSArray*)itemsForListAdapter:(id)arg1 ;
-(void)feedNetworkSource:(id)arg1 willLoadItemsFromResponse:(NSDictionary*)arg2;
-(void)feedNetworkSource:(id)arg1 didFinishLoadingObjects:(NSArray*)arg2 forFetchAction:(int)arg3 ;
-(void)feedNetworkSource:(id)arg1 didChangeToObjects:(id)arg2 ;
- (NSArray*)getMutedList:(NSArray*)items; // new
@end

@interface IGCollectionViewController
- (void)onPullToRefresh:(id)fp8;
- (void)finishRefreshFromPullToRefreshControl;
@end

@interface IGMediaCaptureViewController
- (BOOL)shouldAutoPlayVideo;
@end

@interface SFSafariViewController : NSObject
-(id)initWithURL:(id)arg1;
@end

@interface IGUserDetailHeaderView : UIView
@property(retain, nonatomic) IGFollowButton *followButton;
@property(retain, nonatomic) IGCoreTextView *infoLabelView;
@property (nonatomic, retain) UIView *infoLabelContainerView;
@property (assign,nonatomic) id delegate;
- (void)coreTextView:(id)arg1 didTapOnString:(id)arg2 URL:(NSURL*)arg3;
- (void)onFeedViewModeChanged:(int)arg1;
- (void)onEditProfileTapped;
- (void)switchUsersController:(id)arg1 tableViewDidSelectRowWithUser:(id)arg2;
- (UILabel *)statusLabel;
- (void)setStatusLabel:(UILabel *)value;
@end

@interface IGUserDetailViewController : IGViewController
@property(retain, nonatomic) IGUserDetailHeaderView *headerView;
- (void)actionSheetDismissedWithButtonTitled:(NSString *)title;
- (IGUser *)user;
- (void)animateSwitchUsersTableView;
- (void)onNeedsFullReload;
- (void)setDisplayingSwitchUsersTableView:(BOOL)arg1;
- (void)setUser:(IGUser *)arg1;
- (void)openSwitcher; // new method
@end

@interface IGNavigationController : UINavigationController
@end

@interface IGRootViewController : UIViewController
@property (nonatomic, retain) IGNavigationController *registrationController;
- (id)topMostViewController;
@end

@interface IGSimpleTableViewCell : UITableViewCell
@end

@interface IGFeedItemTextCell : IGSimpleTableViewCell
@property(retain, nonatomic) IGFeedItem *feedItem;
@property(retain, nonatomic) IGCoreTextView *coreTextView;
@property(weak, nonatomic) UINavigationController *navigationController;
- (IGStyledString*)styledStringForLikesWithFeedItem:(IGFeedItem*)item;
- (void)layoutSubviews;
- (int)accessibilityElementCount;
- (id)accessibilityElementAtIndex:(int)index;
- (id)accessibleElements;
@end

@interface IGShakeWindow : UIWindow
- (id)rootViewController;
@end

@interface IGActionSheet : UIActionSheet
@property (nonatomic, retain) NSMutableArray *buttons;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic,copy) NSString * actionSheetTitle;
+ (void)hideImmediately;
- (void)addButtonWithTitle:(NSString *)title style:(int)style;
- (void)buttonWithTitle:(NSString *)title style:(int)style;
- (void)setActionDelegate:(id)arg1 ;
- (void)addButtonWithTitle:(id)arg1 style:(int)arg2 image:(id)arg3 accessibilityIdentifier:(id)arg4 ;
+ (int)tag;
+ (void)setTag:(int)arg1;
- (void)hideAndReset;
@end

@interface IGActionSheetCallbackProxy
- (void)setCallback:(id)arg1 ;
+ (id)delegateWithCallback:(/*^block*/id)arg1 ;
- (void)actionSheetDismissedWithButtonTitled:(NSString*)arg1 ;
- (void)actionSheetFinishedHiding;
@end

@protocol IGFeedHeaderItem <NSObject>
@property (readonly) IGDate *takenAt;
@end

@interface IGFeedItemHeaderViewModel : NSObject
@property (nonatomic,readonly) IGFeedItem *feedItem;
@end

@interface IGFeedItemHeader : UIView
@property (nonatomic, retain) UIButton *timestampButton;
@property (nonatomic, retain) UILabel *timestampLabel;
@property (nonatomic, retain) id<IGFeedHeaderItem> feedItem;
@property (nonatomic,readonly) IGFeedItemHeaderViewModel *viewModel;
- (BOOL)sponsoredPostAllowed;
-(void)onChevronTapped:(id)arg1 ;
@end

@interface IGFeedItemTimelineLayoutAttributes
- (BOOL)sponsoredContext;
@end


@interface IGCollectionView : UICollectionView
@end

@interface IGCollectionViewCell : UICollectionViewCell
@end

@interface IGInternalCollectionView
- (id)visibleIndexPaths;
@end

@interface IGCustomLocationDataSource : NSObject
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 customLocationCellForRowAtIndexPath:(id)arg2;
@end

@interface IGRequest
@end

@interface IGStorableObject : NSObject
- (id)initWithDictionary:(id)arg1;
@end

@interface IGLocation : IGStorableObject
- (id)dictionaryRepresentation;
- (id)name;
- (void)setLocationCoord:(CLLocation *)arg1;
- (void)setStreetAddress:(NSString *)arg1;
- (void)setExternalSource:(NSString *)arg1;
- (void)setExternalIDSource:(NSString *)arg1;
- (void)setFacebookPlacesID:(NSString *)arg1;
- (void)setFoursquareV2ID:(NSString *)arg1;
- (void)setName:(NSString *)arg1;
@end

@interface IGLocationDataSource : NSObject <UITableViewDataSource>
@property (nonatomic, retain) NSString *responseQueryText;
- (id)tableView:(id)arg1 errorCellForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 statusCellForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 attributionCellForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 locationCellForRowAtIndexPath:(id)arg2;

- (void)reloadData;
- (int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (int)numberOfSectionsInTableView:(id)arg1;
- (BOOL)isLoading;
- (void)setIsLoading:(BOOL)arg1;
- (NSArray *)locations;
@end

@interface IGURLHelper : NSObject
+ (void)openExternalURL:(id)arg1 controller:(id)arg2 modal:(BOOL)arg3 controls:(BOOL)arg4 completionHandler:(/*^block*/id)arg5;
@end

@interface IGImageView : UIImageView
@end

@interface IGImageProgressView : UIView
@property (nonatomic,readonly) IGImageView *photoImageView;
@end

@interface IGFeedMediaView : UIView <UIGestureRecognizerDelegate, UIGestureRecognizerDelegate, NYTPhotosViewControllerDelegate>
@property (nonatomic, retain) IGPost *post;
@property (nonatomic,readonly) IGImageProgressView *photoImageView;
@end

@interface IGDirectContent : NSObject
@end

@interface IGDirectContentCell : UICollectionViewCell <UIGestureRecognizerDelegate, NYTPhotosViewControllerDelegate, UIActionSheetDelegate>
@property (nonatomic, retain) IGDirectContent *content;
@property (nonatomic, retain) UILongPressGestureRecognizer *contentMenuLongPressRecognizer;
- (void)onContentMenuPress:(id)arg1;
@end

@interface IGDirectContentExpandableCell : IGDirectContentCell <UIGestureRecognizerDelegate>
- (void)layoutSubviews;
@end

@interface IGDirectPhoto
@property (nonatomic, retain) IGPhoto *photo;
@end

@interface IGDirectVideo : IGDirectContent
@property (nonatomic, retain) IGVideo *video;
@end

@interface IGDirectPhotoExpandableCell
@property (nonatomic, retain) IGImageProgressView *photoImageView;
- (void)layoutSubviews;
@end

@interface IGDirectedPost
- (void)performRead;
- (BOOL)isRead;
- (void)setIsRead:(BOOL)read;
@end

@interface IGDirectThreadViewController
- (void)sendSeenTimestampForContent:(id)arg1;
@end

@interface IGDirectedPostRecipient
- (BOOL)hasRead;
- (void)setHasRead:(BOOL)arg1;
@end

@interface IGDirectThread
- (id)seenAtForItemsWithId:(id)arg1;
@end

@interface IGDirectSharingHelper
+ (id)seenUsersForContent:(id)arg1 thread:(id)arg2 pendingMode:(BOOL)arg3;
@end

@interface IGFeedItemPhotoCell
@property (nonatomic, retain) IGPost *post;
-(void)feedPhotoDidDoubleTapToLike:(id)arg1 ;
@end

@interface IGSimpleButton : UIButton
@end

@interface IGProfilePictureImageView : IGImageView <UIGestureRecognizerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, retain) IGUser *user;
@property (assign,nonatomic) BOOL buttonDisabled;
@property (nonatomic,readonly) IGSimpleButton * profilePicButton;
@property (assign,nonatomic) BOOL isInProfile;
@property (assign,nonatomic) BOOL didDoubleTap;
@property (assign,nonatomic) BOOL didTap;
-(void)updateHighlightedBackgroundColor;
-(void)setHasHighlightedState:(BOOL)arg1 ;
- (id)initWithFrame:(CGRect)arg1;
- (id)initWithFrame:(CGRect)arg1 user:(id)arg2;
- (void)tapped:(id)arg1;
- (void)setButtonDisabled:(BOOL)arg1;
- (BOOL)buttonDisabled;
- (void)longPressed:(id)sender;
- (void)displayProfilePic;
@end

@interface IGFeedToggleView : UIView
+ (id)feedToggleViewForUserHeader;
+ (id)feedToggleViewForProfileHeader;
@end

@interface Appirater : NSObject
- (void)showRatingAlert;
@end

@interface IGFeedNetworkSource
+ (id)feedWithLatest;
-(void)willFetchDataWithParameters:(NSDictionary*)arg1 ;
-(id)URLToFetch:(int)arg1 parameters:(NSDictionary*)arg2 ;
@end



@interface IGMainFeedNetworkSource
-(BOOL)fetchDataWithParameters:(id)arg1 ;
@end

@interface IGUsertagGroup
@property (assign,nonatomic) IGFeedItem *feedItem;
@end

@interface IGFeedPhotoView
@property (nonatomic, retain) IGUsertagGroup *usertags;
@property (assign,nonatomic) IGFeedItemPhotoCell *parentCellView;
- (void)onDoubleTap:(id)arg1;
@end

@interface IGFeedItemVideoView
@property (nonatomic,readonly) IGPost *post;
- (void)onDoubleTap:(id)arg1;
@end

@interface SBMediaController
+ (id)sharedInstance;
- (BOOL)isRingerMuted;
@end

@interface IGVideoPlayer : NSObject
@property (assign,nonatomic) BOOL muted;
- (BOOL)isMuted;
- (void)setMuted:(BOOL)arg1;
- (void)playFromStart;
- (void)stop;
@end

@interface IGFeedVideoPlayer : NSObject
@property (assign,nonatomic) BOOL audioEnabled;
@property (nonatomic,readonly) BOOL supportsAutoplay;
@property (assign,nonatomic) BOOL disallowVideoStart;
- (BOOL)supportsAutoplay;
- (BOOL)disallowVideoStart;
- (BOOL)isAudioEnabled;
- (void)setAudioEnabled:(BOOL)arg1;
- (void)setReadyToPlay:(BOOL)arg1;
- (void)play;
- (id)player;
@end

@interface IGFeedItemVideoCell
@property (nonatomic, retain) IGFeedItemVideoView *videoView;
- (id)post;
- (void)feedItemVideoViewDidDoubleTap:(id)arg1 ;
@end

@interface IGFeedVideoCellManager
- (BOOL)startVideoForCellIfApplicable:(id)arg1 ;
-(void)startVideoIfAutoplayCellExists;
-(BOOL)autoPlayAllowedForVideoCell:(id)arg1 ;
-(BOOL)feedIsScrolling;
-(id)videoCellForAutoPlay;
@end

@interface IGTableView : UITableView
@end

@interface IGGroupedTableView : IGTableView
@end

@interface IGPlainTableViewController : IGViewController <UITableViewDelegate>
@property (nonatomic, retain) IGTableView *tableView;
@end

@interface IGPlainTableView : IGTableView
@end

@interface IGPlainTableViewCell : UITableViewCell
@end

@interface IGGroupedTableViewController : IGPlainTableViewController
@end

@interface IGGroupedTableViewCell : UITableViewCell
@end

@interface IGAccountSettingsViewController : IGGroupedTableViewController
- (id)aboutSectionRows;
- (id)followSectionRows;
- (id)settingSectionRows;
- (id)sessionSectionRows;
- (void)tableView:(id)arg1 didSelectSettingsRow:(int)arg2;
@end

@interface IGTabBarController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic,readonly) UIView *tabBar;
- (void)profileButtonPressed;
- (void)profileButtonLongPressed:(id)arg1;
- (void)animateSwitchUsersTableView;
- (void)setIsDisplayingSwitchUsersTableView:(BOOL)arg1;
- (id)navigationControllerForTabBarItem:(int)arg1;
- (int)selectedTabBarItem;
@end

@interface IGAuthService
+ (IGAuthService*)sharedAuthService;
- (IGAuthenticatedUser *)currentUser;
- (void)setCurrentUser:(IGAuthenticatedUser *)arg1;
- (void)logInWithUsername:(id)arg1 password:(id)arg2 userInfo:(id)arg3 completionHandler:(void(^)(IGAuthenticatedUser *user))completion;
@end

@protocol LocationSelectionDelegate <NSObject>
@required
- (void)didSelectLocation:(CLLocationCoordinate2D)location;
@end

@interface IGLocationPickerViewController : UIViewController <LocationSelectionDelegate>
- (void)locationPickerViewController:(id)arg1 didFinish:(BOOL)arg2 withLocation:(id)arg3;
- (IGLocation *)tempLocation;
- (void)setTempLocation:(IGLocation *)value;
@end

@interface LocationSelectorViewController : UIViewController <UIGestureRecognizerDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, nonatomic) id<LocationSelectionDelegate> delegate;
- (void)hideSelection;
@end

@interface IGNewsStory : NSObject
@property (nonatomic, retain) IGUser *user;
@property (nonatomic,copy) NSString *payload;
@property (nonatomic,retain) NSArray * mediaDictionaries;
-(IGNewsStory*)initWithDictionary:(NSDictionary*)arg1 ;
@property (assign,nonatomic) BOOL shouldMute;
@end

@interface IGNewsBaseTableViewCell : UITableViewCell
@property (nonatomic, retain) IGNewsStory *story;
@end

@interface IGNewsTableViewCell : IGNewsBaseTableViewCell
@end

@interface IGNewsTableViewController : IGGroupedTableViewController
+ (id)storiesWithDictionaries:(id)arg1;
- (void)onDataReceived:(NSArray*)stories ;
@end

@interface IGNewsFollowingTableViewController : IGNewsTableViewController
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
-(void)onStoriesReceived:(id)arg1 ;
@end

@interface IGWebViewController : IGFeedViewController
- (BOOL)isModal;
@end

@interface SBRemoteNotificationServer
- (void)noteDidReceiveMessage:(id)arg1 withType:(long long)arg2 fromClient:(id)arg3;
@end

@interface BBSound : NSObject
+ (id)alertSoundWithSystemSoundID:(unsigned long)arg1;
+ (id)alertSoundWithSystemSoundPath:(id)arg1;
@end

@interface BBBulletin : NSObject
@property (nonatomic, retain) BBSound *sound;
@property (nonatomic, copy) NSString *accountIdentifier;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, retain) NSDictionary *context;
@property (nonatomic, copy) NSString *section;
- (BBSound*)sound;
- (id)message;
@end

@interface IGGrowingTextView : UIView
@property (assign,nonatomic) int keyboardType;
@property (assign,nonatomic) int keyboardAppearance;
@property (assign,nonatomic) int returnKeyType;
@property (assign,nonatomic) BOOL enablesReturnKeyAutomatically;
- (void)setMaxNumberOfLines:(int)arg1;
- (void)setKeyboardType:(int)arg1;
- (void)textViewDidBeginEditing:(UITextView*)arg1 ;
- (BOOL)textViewShouldBeginEditing:(UITextView*)arg1;
- (BOOL)textView:(id)arg1 shouldChangeTextInRange:(NSRange)arg2 replacementText:(id)arg3;
- (void)textViewDidChange:(id)arg1;
- (void)updateTextView;
- (void)updateSizeConstraints;
@end

@interface IGCommentThreadViewController : IGViewController
@property (nonatomic, retain) IGGrowingTextView *growingTextView;
@property (nonatomic, retain) UIView *keyboard;
- (BOOL)growingTextViewShouldReturn:(id)arg1;
- (BOOL)growingTextView:(id)arg1 shouldChangeTextInRange:(NSRange)arg2 replacementText:(id)arg3;
- (void)growingTextViewDidChange:(id)arg1;
- (void)growingTextView:(id)arg1 willChangeHeight:(float)arg2;
@end

@interface IGCaptionCell : UICollectionViewCell
@property (nonatomic,retain) NSString *text;
@end

@interface IGMediaMetadata : NSObject
@property (nonatomic,copy) NSString * caption;
@property (nonatomic,retain) UIImage * snapshot;
@property (nonatomic,readonly) int mediaType;
@end


@interface IGShareViewController : IGViewController
@property (nonatomic,retain) IGCaptionCell *captionCell;
@property (nonatomic,retain) IGMediaMetadata * mediaMetadata;
-(id)initWithMediaMetadata:(id)arg1 ;
@end

@interface IGEditorViewController
@property (nonatomic,readonly) UIImage * image;
@property (assign,getter=isReadyToProceed,nonatomic) BOOL readyToProceed;
-(id)initWithPhotoOrigin:(int)arg1 sourceType:(int)arg2 mediaMetadata:(id)arg3 ;
// DEPRECATED 8.5.1
-(id)initForImageFromCameraWithMediaMetadata:(id)arg1 ;
// REPLACED 8.5.1
-(id)initForImageFromCameraWithMediaMetadata:(id)arg1 userSession:(id)arg2 ;
-(void)setImage:(id)arg1 cropRect:(CGRect)arg2 ;
@end

@interface IGCameraNavigationController : NSObject
-(void)setCurrentEditor:(IGEditorViewController *)arg1 ;
-(id)initWithMetadata:(id)arg1 mode:(int)arg2 ;
-(void)pushViewController:(id)arg1 animated:(BOOL)arg2 ;

@end

@interface IGMainAppViewController
-(void)presentCameraWithMetadata:(id)arg1 mode:(int)arg2 ;
-(IGCameraNavigationController *)cameraController;
@end

@interface IGRootView : UIView
@end

@interface IGVideoMetadata
-(void)setRawVideoLocationString:(NSString *)arg1 ;
@end

@interface IGVideoEditorViewController
-(id)initWithAssetInMediaMetadata:(id)arg1 ;
-(id)initWithOrigin:(int)arg1 videoInfo:(id)arg2 mediaMetadata:(id)arg3 ;
@end

@interface IGVideoConfiguration

@end

@interface IGVideoComposition
@property (nonatomic,retain) NSArray * clips;
-(id)initWithVideoConfiguration:(IGVideoConfiguration*)arg1 ;
-(void)addClip:(id)arg1 ;

@end

@interface IGVideoClip
-(id)initWithAsset:(id)arg1 position:(int)arg2 sourceType:(int)arg3 ;
@end

@interface IGVideoInfo : NSObject
@property (nonatomic,retain) IGVideoComposition * video;
@end


@interface IGExperimentUserGroup : NSObject
@property (nonatomic,readonly) NSDictionary * parameters;
@property (nonatomic,readonly) NSString * name;
-(id)initWithName:(id)arg1 parameters:(id)arg2 ;
@end

@interface IGExperimentSet {
  NSMutableDictionary* _cachedExperiments;
}
-(BOOL)updateExperimentsWithPayload:(NSDictionary*)arg1 ;
-(NSArray *)defaultExperiments;
-(id)experiments;
-(id)experimentForKey:(id)arg1 ;
-(void)loadDiskCache;
-(id)diskCacheFilePath;
-(void)setOverrideGroup:(id)arg1 forExperimentSpec:(id)arg2 ;
@end

@interface IGExperimentGroup
@property (nonatomic,readonly) NSDictionary * parameters;
-(id)initWithName:(id)arg1 parameters:(NSDictionary*)arg2 ;
@end

@interface IGExperimentSpec : NSObject
@property (nonatomic,copy) NSString * key;
@property (nonatomic,copy,readonly) NSArray * predefinedGroups;
@end

@interface IGExperiment
@property (nonatomic,retain) IGExperimentUserGroup * serverSideUserGroup;
@property (nonatomic,copy) NSString * key;
@property (nonatomic,copy,readonly) NSArray * predefinedGroups;
-(void)setOverrideGroup:(IGExperimentGroup *)arg1 ;
@end

@interface IGExperimentManager
+(IGExperiment*)experimentForKey:(id)arg1 ;
@end

@interface IGMainAppCollectionView : UICollectionView
-(BOOL)gestureRecognizerShouldBegin:(id)arg1 ;
@end

@interface IGAlbumTrayCollectionViewCell : UICollectionViewCell
-(void)layoutSubviews;
-(void)willMoveToWindow:(id)arg1 ;
@end

@interface IGVerticalCollectionViewLayout : UICollectionViewLayout
-(id)layoutAttributesForElementsInRect:(CGRect)arg1 ;
-(UICollectionViewLayoutAttributes*)layoutAttributesForItemAtIndexPath:(NSIndexPath*)arg1 ;
@end

@interface IGAlbumViewerViewModel : NSObject
@property (nonatomic,readonly) IGUser * user;
@property (nonatomic,readonly) BOOL isCurrentUser;
@property (nonatomic,readonly) BOOL isNux;
@property (nonatomic,readonly) BOOL canReply;
@property (nonatomic,copy,readonly) NSArray * items;
@end

@interface IGAlbumViewerViewController : IGViewController
@property (nonatomic,retain) IGAlbumViewerViewModel * focusedModelItem;
@end

@interface IGListItemController : NSObject

@end

@interface IGFeedItemController : IGListItemController
@property (nonatomic,readonly) IGFeedItem * feedItem;
-(void)actionSheetDismissedWithButtonTitled:(NSString*)title;
-(void)feedItemHeaderDidTapOnMoreButton:(id)arg1 ;
@end

@protocol IGAlbumItemType <NSObject>
@required
-(id)mediaID;
-(id)takenAtDate;
-(id)feedItem;
-(id)pendingUpload;
-(int)viewerCount;
-(id)albumChannelPK;
-(id)viewers;
-(id)user;
-(int)mediaType;
-(id)photo;
-(char)shouldLoop;
-(double)totalDuration;
-(id)video;
@end


@protocol IGAlbumItemActionsControllerDelegate <NSObject>
@required
-(void)albumItemActionsControllerWillSavePost:(id)arg1;
-(void)albumItemActionsControllerWillDeletePost:(id)arg1;
-(void)albumItemActionsControllerWillSharePost:(id)arg1;
-(void)albumItemActionsControllerWillReportPost:(id)arg1;
-(void)albumItemActionsControllerDidFinish:(id)arg1;

@end

@protocol IGAlbumFullScreenItemControllerDelegate <NSObject>
@required
-(void)fullscreenItemController:(id)arg1 willUpdateFromAlbumModel:(id)arg2 toAlbumModel:(id)arg3 albumItem:(id)arg4;
-(void)fullscreenItemController:(id)arg1 didChangeItemWithNavigationAction:(int)arg2;
-(char)fullscreenItemControllerCanResumePlayback:(id)arg1;
-(void)fullscreenItemController:(id)arg1 didMarkItemAsSeen:(id)arg2;
-(void)fullscreenItemController:(id)arg1 didAdvancePastLastItemWithNavigationAction:(int)arg2;
-(void)fullscreenItemController:(id)arg1 didRewindPastFirstItemWithNavigationAction:(int)arg2;
-(void)fullscreenItemControllerDidTapDismiss:(id)arg1;

@end



@interface IGAlbumFullscreenItemController : IGListItemController
@property (assign,nonatomic) id<IGAlbumFullScreenItemControllerDelegate> delegate;
-(void)markItemAsSeen;
-(void)headerViewDidTapDismiss:(id)arg1 ; // no arg needed, no crash
@end

@interface IGAlbumItemActionsController : NSObject
@property (nonatomic,retain) IGUserSession * userSession;
@property (nonatomic,retain) id<IGAlbumItemType> item;
@property (assign,nonatomic) id<IGAlbumItemActionsControllerDelegate> delegate;
-(void)actionSheetDismissedWithButtonTitled:(NSString*)title;
@end

@interface IGHScrollAYMFBannerCell : UICollectionViewCell

@end

@interface IGAlbumCameraViewController

@end

@interface IGAlbumCreationViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic,readonly) IGAlbumCameraViewController * cameraViewController;
-(void)cameraPreviewViewControllerDidTapShare:(id)arg1 asset:(id)arg2 albumModel:(id)arg3 ;
-(void)albumCameraViewController:(id)arg1 didOutputAsset:(id)arg2 ;
-(void)uploadContent:(id)sender; //new
- (UIImage *)scaleImageToSize:(CGSize)newSize withImage:(UIImage*)image;
@end

@interface IGQuickCamOutputVideoAsset : NSObject
@property (assign,nonatomic) BOOL isFromLibrary;
@property (nonatomic,readonly) IGVideoClip * clip;
@property (nonatomic,retain) IGVideoInfo * videoInfo;
@property (nonatomic,retain) UIImage * displayImage;
@property (nonatomic,retain) UIImage * croppedImage;
@property (nonatomic,retain) UIImage * croppedImageWithEdits;
@end

@interface IGQuickCamOutputPhotoAsset : NSObject
@property (nonatomic,retain) UIImage * displayImage;
@property (nonatomic,retain) UIImage * fullSizeImage;
@property (nonatomic,retain) UIImage * croppedImage;
@property (nonatomic,retain) UIImage * croppedImageWithEdits;
@property (assign,nonatomic) BOOL isFromLibrary;
@property (nonatomic,readonly) BOOL isPhoto;
@end

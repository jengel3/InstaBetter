#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "lib/Protocols/NYTPhoto.h"
#import "lib/NYTPhotoViewController.h"
#import "lib/NYTPhotosViewController.h"

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

@interface IGAuthHelper
@property (nonatomic,retain) IGUser * currentUser; 
+(id)sharedAuthHelper;
-(void)logInWithAuthenticatedUser:(id)arg1 ;
-(void)switchToAuthenticatedUser:(id)arg1 failureBlock:(id)arg2 ;
-(void)logInWithAuthenticatedUser:(id)arg1 isSwitchingUsers:(char)arg2 ;
-(void)clearCurrentUser;
@end

@interface IGAuthenticatedUser

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

@property (nonatomic,readonly) long long microseconds;
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

@interface IGFeedItemActionCell : UICollectionViewCell
@property(retain, nonatomic) IGFeedItem *feedItem;
@property (nonatomic,retain) UIButton * sendButton; 
@property (nonatomic,retain) UIButton * commentButton;
@property (nonatomic,retain) UIButton * likeButton;
-(BOOL)sponsoredPostAllowed;
-(id)initWithFrame:(CGRect)frame;
-(void)actionSheetDismissedWithButtonTitled:(NSString *)title;
-(UINavigationController*)window;
- (UIButton *)saveButton;
- (void)setSaveButton:(UIButton *)value;
-(void)shareItem:(id)sender;
-(void)saveItem:(id)sender;
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

@interface IGSwitchUsersController : NSObject <UITableViewDelegate, UITableViewDataSource> {

  char _shouldShowAddAccountRow;
  UITableView* _tableView;
  NSArray* _usersArray;
  int _currentUserIndex;

}

@property (nonatomic,retain) UITableView * tableView;                                          
@property (nonatomic,retain) NSArray * usersArray;                                        
@property (assign,nonatomic) int currentUserIndex;                                            
@property (assign,nonatomic) BOOL shouldShowAddAccountRow;                                  
-(void)imageViewLoadedImage:(id)arg1 ;
-(id)initWithShouldShowAddAccountRow:(BOOL)arg1 ;
-(float)minimumTableViewHeight;
-(void)updateCurrentUserIndex;
-(void)updateUserData;
-(NSArray *)usersArray;
-(void)setCurrentUserIndex:(int)arg1 ;
-(void)setUsersArray:(NSArray *)arg1 ;
-(BOOL)shouldShowAddAccountRow;
-(id)userCellForTableView:(id)arg1 indexPath:(id)arg2 ;
-(id)addAccountCellForTableView:(id)arg1 indexPath:(id)arg2 ;
-(int)currentUserIndex;
-(void)setShouldShowAddAccountRow:(BOOL)arg1 ;
-(void)dealloc;
-(float)tableView:(id)arg1 heightForHeaderInSection:(int)arg2 ;
-(float)tableView:(id)arg1 heightForFooterInSection:(int)arg2 ;
-(void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2 ;
-(int)tableView:(id)arg1 numberOfRowsInSection:(int)arg2 ;
-(id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2 ;
-(void)setTableView:(UITableView *)arg1 ;
-(UITableView *)tableView;
-(id)users;

@end

@interface IGUserDetailHeaderView : UIView
@property(retain, nonatomic) IGFollowButton *followButton;
@property(retain, nonatomic) IGCoreTextView *infoLabelView;
-(void)coreTextView:(id)arg1 didTapOnString:(id)arg2 URL:(id)arg3 ;
@property (assign,nonatomic) id delegate;
-(void)onFeedViewModeChanged:(int)arg1 ;
-(void)onEditProfileTapped;
@end

@interface IGUserDetailViewController : IGViewController
-(void)actionSheetDismissedWithButtonTitled:(NSString *)title;
-(IGUser *)user;
@property(retain, nonatomic) IGUserDetailHeaderView *headerView;
-(void)setSwitchUsersTitleView;
@property (nonatomic,retain) IGSwitchUsersController * switchUsersController;
@end

@interface IGNavigationController : UINavigationController
@end

@interface IGRootViewController : UIViewController
@property (nonatomic,retain) IGNavigationController * registrationController; 
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

@interface IGActionSheet : UIActionSheet
@property (nonatomic,retain) NSMutableArray * buttons; 
@property (nonatomic,retain) UILabel * titleLabel;  
- (void)addButtonWithTitle:(NSString *)title style:(int)style;
+(int)tag;
+(void)setTag:(int)arg1 ;
@end

@protocol IGFeedHeaderItem <NSObject>
@property (readonly) IGDate * takenAt; 
@end

@interface IGFeedItemHeader : UIView
@property (nonatomic,retain) UIButton * timestampButton;
@property (nonatomic,retain) UILabel * timestampLabel;
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

@interface IGDirectContent : NSObject

@end

@interface IGDirectContentCell : UICollectionViewCell <UILongPressGestureRecognizerDelegate, NYTPhotosViewControllerDelegate, UIActionSheetDelegate>
@property (nonatomic,retain) IGDirectContent * content;
-(void)onContentMenuPress:(id)arg1 ;
@property (nonatomic,retain) UILongPressGestureRecognizer * contentMenuLongPressRecognizer;
@end


@interface IGDirectContentExpandableCell : IGDirectContentCell <UILongPressGestureRecognizerDelegate>
-(void)layoutSubviews;
@end

@interface IGDirectPhoto
@property (nonatomic,retain) IGPhoto * photo;
@end

@interface IGDirectVideo : IGDirectContent
@property (nonatomic,retain) IGVideo * video;
@end 


@interface IGDirectPhotoExpandableCell 
@property (nonatomic,retain) IGImageProgressView * photoImageView; 
-(void)layoutSubviews;
@end

@interface IGDirectedPost
-(void)performRead;
-(BOOL)isRead;
-(void)setIsRead:(BOOL)read;
@end

@interface IGDirectThreadViewController
-(void)sendSeenTimestampForContent:(id)arg1 ;
@end

@interface IGDirectedPostRecipient
-(BOOL)hasRead;
-(void)setHasRead:(BOOL)arg1 ;
@end

@interface IGDirectThread
-(id)seenAtForItemsWithId:(id)arg1 ;
@end

@interface IGDirectSharingHelper
+(id)seenUsersForContent:(id)arg1 thread:(id)arg2 pendingMode:(char)arg3;
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

@interface IGTableView : UITableView
@end

@interface IGGroupedTableView : IGTableView
@end

@interface IGPlainTableViewController : IGViewController
@property (nonatomic,retain) IGTableView * tableView; 
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
-(id)aboutSectionRows;
-(id)followSectionRows;
-(id)settingSectionRows;
-(id)sessionSectionRows;
-(void)tableView:(id)arg1 didSelectSettingsRow:(int)arg2 ;
@end

@interface IGTabBarController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic,readonly) UIView * tabBar; 
@property (nonatomic,retain) IGSwitchUsersController * switchUsersController;
-(void)profileButtonPressed;
-(void)profileButtonLongPressed:(id)arg1 ;
-(void)animateSwitchUsersTableView;
-(void)setIsDisplayingSwitchUsersTableView:(char)arg1 ;
-(id)navigationControllerForTabBarItem:(int)arg1 ;
-(int)selectedTabBarItem;

@end

@interface IGAuthService
+(id)sharedAuthService;
-(void)logInWithUsername:(id)arg1 password:(id)arg2 userInfo:(id)arg3 completionHandler:(void(^)(IGAuthenticatedUser *user))completion ;
@end
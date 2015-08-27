#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface IGUser : NSObject
@property (strong, nonatomic) NSString *username;
+(void)fetchFollowStatusInBulk:(NSArray*)users;
-(id)followingCount;
-(id)followerCount;
-(void)fetchAdditionalUserDataWithCompletion:(id)fp8;

-(id)initWithDictionary:(id)data;

-(void)onFriendStatusReceived:(NSDictionary*)status;


- (id)secondaryName;
- (id)primaryName;
- (id)fullOrDisplayName;
- (id)toDict;
@property int lastFollowStatus;
@property int followStatus; 
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

@interface IGPost : NSObject
@property (strong, nonatomic) IGUser *user;
-(id)init;
-(id)initWithCoder:(id)fp8;
-(int)likeCount;
@end

@interface IGFeedItem : IGPost
-(id)description;
-(BOOL)isHidden;
-(id)getMediaId;
-(void)setIsHidden:(BOOL)hidden;
-(id)initWithCoder:(id)fp8;
-(id)init;
@end

@interface IGFeedItemActionCell
-(BOOL)sponsoredPostAllowed;
-(id)initWithFrame:(CGRect)frame;
-(UIButton*)likeButton;
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
- (void)checkFriendshipStatus;
- (BOOL)shouldShowFriendStatus;
@property(retain, nonatomic) IGUserDetailHeaderView *headerView;
@end

@interface IGRootViewController : UIViewController
-(id)topMostViewController;
@end

@interface IGSimpleTableViewCell : UITableViewCell
@end

@interface IGFeedItemTextCell : IGSimpleTableViewCell
-(IGStyledString*)styledStringForLikesWithFeedItem:(IGFeedItem*)item;
@property(retain, nonatomic) IGFeedItem *feedItem; // @synthesize feedItem=_feedItem;
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
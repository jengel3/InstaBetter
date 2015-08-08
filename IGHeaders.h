#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "substrate.h"

@interface IGUser : NSObject
	@property (strong, nonatomic) NSString *username;
	+(void)fetchFollowStatusInBulk:(id)fp8;
	-(id)followingCount;
	-(id)followerCount;
	-(void)fetchAdditionalUserDataWithCompletion:(id)fp8;
	-(void)fetchFollowStatus;
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
-(id)initWithFrame:(CGRect)frame;
@end

@interface AppDelegate : NSObject
- (void)startMainAppWithMainFeedSource:(id)source animated:(BOOL)animated;
- (id)window; 
@end

@interface IGMainFeedViewController
-(BOOL)shouldHideFeedItem:(id)fp8;
@end

@interface IGFeedViewController
-(void)handleDidDisplayFeedItem:(IGFeedItem*)item;
@end

@interface IGViewController : UIViewController
@end

@interface IGUserDetailViewController : IGViewController
-(void)actionSheetDismissedWithButtonTitled:(NSString *)title;
-(IGUser *)user;
@end

@interface IGRootViewController : UIViewController
- (id)topMostViewController;
@end

@interface IGStyledString
-(id)attributedString;
-(void)appendString:(id)str;
@end

@interface IGFeedItemTextCell
-(IGStyledString*)styledStringForLikesWithFeedItem:(IGFeedItem*)item;
@end

@interface IGShakeWindow : UIWindow

- (id)rootViewController;

@end

@interface IGActionSheet
- (void)addButtonWithTitle:(NSString *)title style:(int)style;
@end

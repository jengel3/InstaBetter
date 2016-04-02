#import <Preferences/PSListController.h>
#import <Preferences/PSEditableListController.h>
#import <Preferences/PSSpecifier.h>

@interface InstaBetterPrefsController : PSListController
@property (nonatomic, retain) NSArray *sounds;
@end

@interface EditableListController : PSEditableListController
@end

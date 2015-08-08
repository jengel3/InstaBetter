#import <Preferences/Preferences.h>

@interface InstaBetterPrefsListController: PSListController {
}
@end

@implementation InstaBetterPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"InstaBetterPrefs" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc

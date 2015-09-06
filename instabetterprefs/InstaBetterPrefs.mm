#import <Preferences/Preferences.h>
@interface InstaBetterPrefsController: PSListController 
@end

@implementation InstaBetterPrefsController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"InstaBetterPrefs" target:self] retain];
	}

	return _specifiers;
}

- (void)openTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/itsjake88"]];
}

- (void)openDesignerTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/AOkhtenberg"]];
}

- (void)openDonate:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=WJZXHG5MSE85L&lc=US&item_name=Jake%27s%20Development&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted"]];
}

@end

@interface EditableListController : PSEditableListController
@end
 
@implementation EditableListController
- (id)specifiers {
	if (!_specifiers) {
		NSMutableArray *specs = [[NSMutableArray alloc] init];
		NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist"];
      	NSArray *keys = [prefs objectForKey:@"muted_users"];
		for (id o in keys) {
	    	PSSpecifier* defSpec = [PSSpecifier preferenceSpecifierNamed:o
										    target:self
										       set:NULL
										       get:NULL
										    detail:Nil
										      cell:PSTitleValueCell
										      edit:Nil];
	    	extern NSString* PSDeletionActionKey;
	    	[defSpec setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
	    	[specs addObject:defSpec];
		}
		_specifiers = [[NSArray alloc] initWithArray:specs];
	}
	return _specifiers;
}

-(void)removedSpecifier:(PSSpecifier*)specifier{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist"];
    NSMutableArray *keys = [prefs objectForKey:@"muted_users"];
    [keys removeObject:[specifier name]];
    [prefs setValue:keys forKey:@"muted_users"];
    [prefs writeToFile:@"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist" atomically:YES];
}

@end

// vim:ft=objc

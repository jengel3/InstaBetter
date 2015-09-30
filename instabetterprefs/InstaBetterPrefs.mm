#import <Preferences/Preferences.h>

@interface InstaBetterPrefsController: PSListController 
@end

@interface EditableListController : PSEditableListController
@end

@implementation InstaBetterPrefsController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"InstaBetterPrefs" target:self];
	}

	return _specifiers;
}

- (void)openTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/itsjake88"]];
}

- (void)openDesignerTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/AOkhtenberg"]];
}

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
    	[defSpec setProperty:NSStringFromSelector(@selector(removedUsername:)) forKey:PSDeletionActionKey];
    	[specs addObject:defSpec];
		}
		_specifiers = [[NSArray alloc] initWithArray:specs];
	}
	return _specifiers;
}

-(void)removedUsername:(PSSpecifier*)specifier{
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist"];
  NSMutableArray *keys = [prefs objectForKey:@"muted_users"];
  [keys removeObject:[specifier name]];
  [prefs setValue:keys forKey:@"muted_users"];
  [prefs writeToFile:@"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist" atomically:YES];
}

@end

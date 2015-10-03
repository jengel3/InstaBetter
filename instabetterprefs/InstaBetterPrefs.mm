#import <Preferences/Preferences.h>
#import "InstaBetterPrefs.h"

NSBundle *ibsBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/InstaBetterPrefs.bundle"];
#define valuesPath @"/User/Library/Preferences/com.jake0oo0.instabetter.plist"

@implementation InstaBetterPrefsController
-(void) viewDidLoad {
  [super viewDidLoad];
  [self reload];
  [self reloadSpecifiers];
}
- (id)specifiers {
  if(_specifiers == nil) {
    [ibsBundle load];
    _specifiers = [self loadSpecifiersFromPlistName:@"InstaBetterPrefs" target:self bundle:ibsBundle];
    NSLog(@"SPECS %@", _specifiers);
    NSLog(@"DATA SOURCE %@", [self specifierDataSource]);
  }
  return _specifiers;
}


// http://iphonedevwiki.net/index.php/PreferenceBundles
-(id) readPreferenceValue:(PSSpecifier*)specifier {
  NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:valuesPath];
  if (!settings[specifier.properties[@"key"]]) {
    return specifier.properties[@"default"];
  }
  return settings[specifier.properties[@"key"]];
}
 
-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:valuesPath]];
  [defaults setObject:value forKey:specifier.properties[@"key"]];
  [defaults writeToFile:valuesPath atomically:YES];
  CFStringRef toPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
  if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}

- (void)openTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/itsjake88"]];
}

- (void)openDesignerTwitter:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/AOkhtenberg"]];
}

-(id) loadSpecifiersFromPlistName:(id)arg1 target:(id)arg2 bundle:(id)arg3 {
  NSLog(@"CALLED %@ -- %@ -- %@", arg1, arg2, arg3);
  return [super loadSpecifiersFromPlistName:arg1 target:arg2 bundle:arg3];
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
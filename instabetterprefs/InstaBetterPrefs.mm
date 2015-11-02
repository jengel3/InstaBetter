#import <Preferences/Preferences.h>
#import "InstaBetterPrefs.h"

NSBundle *ibsBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/InstaBetterPrefs.bundle"];
#define valuesPath @"/User/Library/Preferences/com.jake0oo0.instabetter.plist"

@implementation InstaBetterPrefsController
- (id)specifiers {
  if(_specifiers == nil) {
    [ibsBundle load];
    _specifiers = [self loadSpecifiersFromPlistName:@"InstaBetterPrefs" target:self bundle:ibsBundle];
  }
  return _specifiers;
}

-(NSArray*)loadSounds:(id)target; {
  NSLog(@"CALLED LOAD!!");
  if (!self.sounds) {
    NSMutableArray *allSounds = [[NSMutableArray alloc] init];

    // NSFileManager *fileManager = [NSFileManager defaultManager];
    // NSString *soundsPath = @"/System/Library/Audio/UISounds/";
    // NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:soundsPath];
    // NSString *subpath;
    // while (subpath = [enumerator nextObject]) {
    //   if ([[subpath pathExtension] isEqualToString:@"caf"]) {
    //     NSString *path = [NSString stringWithFormat:@"%@%@", soundsPath, subpath];
    //     if (![allSounds containsObject:path]) {
    //       [allSounds addObject:path];
    //     }
    //   }
    // }
    self.sounds = allSounds;
  }


  return self.sounds;
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
  [defaults writeToFile:valuesPath atomically:NO];
  CFStringRef toPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
  if (toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}
// end

- (void)openTwitter:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/itsjake88"]];
}

- (void)openDesignerTwitter:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.twitter.com/AOkhtenberg"]];
}

- (void)restartInstagram:(id)sender {
  if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.burbn.instagram"]) {
    return exit(0);
  }
  system("killall -9 Instagram");
}

@end
 
@implementation EditableListController
- (id)specifiers {
  if (!_specifiers) {
    NSMutableArray *specs = [[NSMutableArray alloc] init];
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:valuesPath];
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

-(void)removedUsername:(PSSpecifier*)specifier {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:valuesPath];
  NSMutableArray *keys = [prefs objectForKey:@"muted_users"];
  [keys removeObject:[specifier name]];
  [prefs setValue:keys forKey:@"muted_users"];
  [prefs writeToFile:valuesPath atomically:NO];
}

@end
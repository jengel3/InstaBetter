#import "InstaBetterPrefs.h"
// #import "../InstaHelper.h"

NSBundle *ibsBundle;
#define valuesPath @"/User/Library/Preferences/com.jake0oo0.instabetter.plist"

@implementation InstaBetterPrefsController
- (id)specifiers {
  if(_specifiers == nil) {
    if (ibsBundle == nil) {
      // BOOL jb = [InstaHelper isJailbroken];
      // if (jb) {
        ibsBundle = [[NSBundle alloc] initWithPath:@"/Library/PreferenceBundles/InstaBetterPrefs.bundle"];
      // } else {
        // ibsBundle = [[NSBundle alloc] initWithURL:[InstaHelper documentsDirectory]];
      // }
    }
    [ibsBundle load];
    if ([self respondsToSelector:@selector(loadSpecifiersFromPlistName:target:bundle:)]) {
      _specifiers = [self loadSpecifiersFromPlistName:@"InstaBetterPrefs" target:self bundle:ibsBundle];
    } else {
      _specifiers = [self loadSpecifiersFromPlistName:@"InstaBetterPrefs" target:self];
    }
  }
  return _specifiers;
}

- (NSArray *)loadSounds {
  if (!self.sounds) {
    NSMutableArray *rawList = [[NSMutableArray alloc] init];
    NSString *soundsPath = @"/System/Library/Audio/UISounds/";

    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:soundsPath error:NULL];
    [rawList addObject:@"(none)"];
    [rawList addObject:@"Default"];
    [files enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
      NSString *filename = (NSString *)obj;
      NSString *extension = [[filename pathExtension] lowercaseString];
      if ([extension isEqualToString:@"caf"]) {
        [rawList addObject:filename];
      }
    }];
    self.sounds = [rawList copy];
  }
  return self.sounds;
}

// http://iphonedevwiki.net/index.php/PreferenceBundles
- (id)readPreferenceValue:(PSSpecifier*)specifier {
  NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:valuesPath];
  if (!settings[specifier.properties[@"key"]]) {
    return specifier.properties[@"default"];
  }
  return settings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:valuesPath]];
  [defaults setObject:value forKey:specifier.properties[@"key"]];
  [defaults writeToFile:valuesPath atomically:NO];
  CFStringRef toPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
  if (toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
}
// end

- (void)openTwitter:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.twitter.com/itsjake88"]];
}

- (void)openDesignerTwitter:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.twitter.com/AOkhtenberg"]];
}

- (void)openPayPal:(id)sender {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/itsjake"]];
}

- (void)restartInstagram:(id)sender {
  if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.burbn.instagram"]) {
    return exit(0);
  }
  // system("killall -9 Instagram");
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
      // extern NSString* PSDeletionActionKey;
      [defSpec setProperty:NSStringFromSelector(@selector(removedUsername:)) forKey:@"deletionAction"];
      [specs addObject:defSpec];
    }
    _specifiers = [[NSArray alloc] initWithArray:specs];
  }
  return _specifiers;
}

- (void)removedUsername:(PSSpecifier*)specifier {
  NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:valuesPath];
  NSMutableArray *keys = [prefs objectForKey:@"muted_users"];
  [keys removeObject:[specifier name]];
  [prefs setValue:keys forKey:@"muted_users"];
  [prefs writeToFile:valuesPath atomically:NO];
}

@end
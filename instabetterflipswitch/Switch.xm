#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"

@interface NSUserDefaults (Tweak_Category)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *prefsLoc = @"/var/mobile/Library/Preferences/com.jake0oo0.instabetter.plist";
// static NSString *nsDomainString = @"com.jake0oo0.instabetterflipswitch";
static NSString *nsNotificationString = @"com.jake0oo0.instabetterflipswitch/preferences.changed";

@interface InstaBetterFlipSwitch : NSObject <FSSwitchDataSource>
@end

@implementation InstaBetterFlipSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"InstaBetter";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
  BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:prefsLoc];
  BOOL enabled;
  if (exists) {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
    if (prefs) {
      enabled = [prefs objectForKey:@"enabled"] ? [[prefs objectForKey:@"enabled"] boolValue] : YES;
    } else {
    	enabled = NO;
    }
  } else {
  	enabled = NO;
  }
	return enabled ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {

	BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:prefsLoc];
  NSMutableDictionary *prefs;
  if (exists) {
    prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:prefsLoc];
  }
	switch (newState) {
	case FSSwitchStateIndeterminate:
		break;
	case FSSwitchStateOn:
		if (prefs) {
			[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"enabled"];
			[prefs writeToFile:prefsLoc atomically:NO];
		}
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)nsNotificationString, NULL, NULL, YES);
		break;
	case FSSwitchStateOff:
		if (prefs) {
			[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"enabled"];
			[prefs writeToFile:prefsLoc atomically:NO];
		}
		break;
	}
	return;
}

@end

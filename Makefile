ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
THEOS_PACKAGE_DIR_NAME = debs
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = InstaBetter
InstaBetter_FILES = InstaHelper.xm Tweak.xm instabetterprefs/InstaBetterPrefs.mm $(wildcard lib/*.m)
InstaBetter_LDFLAGS += -Wl,-segalign,4000
InstaBetter_FRAMEWORKS = UIKit AVFoundation Foundation CoreGraphics ImageIO Accelerate QuartzCore MapKit CoreLocation AssetsLibrary
InstaBetter_WEAK_FRAMEWORKS = Photos
InstaBetter_PRIVATE_FRAMEWORKS = Preferences BulletinBoard

include $(THEOS_MAKE_PATH)/tweak.mk
include theos/makefiles/bundle.mk

after-install::
	install.exec "killall -9 Instagram && activator send com.bd452.bypass && activator send com.burbn.instagram"
	install.exec "killall -9 Preferences"
	install.exec "activator send com.bd452.bypass"
	install.exec "activator send com.burbn.instagram"

SUBPROJECTS += instabetterprefs
SUBPROJECTS += instabetterflipswitch
include $(THEOS_MAKE_PATH)/aggregate.mk

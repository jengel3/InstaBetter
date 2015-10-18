ARCHS = armv7 arm64
TARGET = :clang
TARGET_IPHONEOS_DEPLOYMENT_VERSION = 7.0
THEOS_PACKAGE_DIR_NAME = debs
ADDITIONAL_OBJCFLAGS = -fobjc-arc

include theos/makefiles/common.mk

TWEAK_NAME = InstaBetter
BUNDLE_NAME = InstaBetterResources
InstaBetterResources_INSTALL_PATH = /Library/Application Support/InstaBetter
InstaBetter_FILES = Tweak.xm instabetterprefs/InstaBetterPrefs.mm $(wildcard lib/*.m)
InstaBetter_FRAMEWORKS = UIKit Foundation CoreGraphics ImageIO Accelerate QuartzCore MapKit CoreLocation
InstaBetter_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
include theos/makefiles/bundle.mk

after-install::
	install.exec "killall -9 Instagram"
SUBPROJECTS += instabetterprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

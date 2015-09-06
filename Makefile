ARCHS = armv7 arm64
TARGET = :clang
THEOS_PACKAGE_DIR_NAME = debs

include theos/makefiles/common.mk

TWEAK_NAME = InstaBetter
BUNDLE_NAME = InstaBetterResources
InstaBetterResources_INSTALL_PATH = /Library/Application Support/InstaBetter
InstaBetter_FILES = MBProgressHUD.m Tweak.xm
InstaBetter_FRAMEWORKS = UIKit Foundation CoreGraphics

include $(THEOS_MAKE_PATH)/tweak.mk
include theos/makefiles/bundle.mk

after-install::
	install.exec "killall -9 Instagram"
SUBPROJECTS += instabetterprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

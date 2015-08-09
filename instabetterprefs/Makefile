ARCHS = armv7 arm64
TARGET = :clang
include theos/makefiles/common.mk

BUNDLE_NAME = InstaBetterPrefs
InstaBetterPrefs_FILES = InstaBetterPrefs.mm
InstaBetterPrefs_INSTALL_PATH = /Library/PreferenceBundles
InstaBetterPrefs_FRAMEWORKS = UIKit
InstaBetterPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/InstaBetterPrefs.plist$(ECHO_END)

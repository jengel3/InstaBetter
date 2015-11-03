ARCHS = armv7 arm64
TARGET = iphone:latest:7.0
ADDITIONAL_OBJCFLAGS = -fobjc-arc
include theos/makefiles/common.mk

BUNDLE_NAME = InstaBetterPrefs
InstaBetterPrefs_FILES = InstaBetterPrefs.mm
InstaBetterPrefs_INSTALL_PATH = /Library/PreferenceBundles
InstaBetterPrefs_LDFLAGS += -Wl,-segalign,4000
InstaBetterPrefs_FRAMEWORKS = UIKit
InstaBetterPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/InstaBetterPrefs.plist$(ECHO_END)

after-install::
	install.exec "killall -9 Preferences"
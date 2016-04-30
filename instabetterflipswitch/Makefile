include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = instabetterflipswitch
instabetterflipswitch_FILES = Switch.xm
instabetterflipswitch_FRAMEWORKS = UIKit
instabetterflipswitch_LIBRARIES = flipswitch
instabetterflipswitch_INSTALL_PATH = /Library/Switches

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	#PreferenceLoader plist
	$(ECHO_NOTHING)if [ -f Preferences.plist ]; then mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/instabetterflipswitch; cp Preferences.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/instabetterflipswitch/; fi$(ECHO_END)

after-install::
	install.exec "killall -9 Instagram"
	install.exec "killall -9 SpringBoard"
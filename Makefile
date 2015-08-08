ARCHS = armv7 arm64
THEOS_PACKAGE_DIR_NAME = debs

include theos/makefiles/common.mk

TWEAK_NAME = InstaBetter
InstaBetter_FILES = Tweak.xm
InstaBetter_FRAMEWORKS = UIKit Foundation

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 Instagram"
SUBPROJECTS += instabetterprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

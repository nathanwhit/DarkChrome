include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkChrome
DarkChrome_FILES = Tweak.xm
DarkChrome_FRAMEWORKS = UIKit Foundation
DarkChrome_CFLAGS = -fobjc-arc
export ARCHS = arm64
export SDKVERSION = 11.2
DEBUG=0
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += darkchromeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
# after-install::
# 	install.exec "killall -9 SpringBoard"

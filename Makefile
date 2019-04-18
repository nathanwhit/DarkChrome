export TARGET = :clang:11.2:11.0
export COPYFILE_DISABLE=1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkChromeBeta
BUNDLE_NAME = com.nwhit.darkchromebund
com.nwhit.darkchromebund_INSTALL_PATH = /Library/Application Support

include $(THEOS)/makefiles/bundle.mk

DarkChromeBeta_FILES = Tweak.xm
DarkChromeBeta_FRAMEWORKS = UIKit Foundation
DarkChromeBeta_CFLAGS += -fobjc-arc
export ARCHS = arm64
DEBUG=0
include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += darkchromeprefs
include $(THEOS_MAKE_PATH)/aggregate.mk

# after-install::
# 	install.exec "killall -9 SpringBoard"

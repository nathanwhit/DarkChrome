include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkChrome
DarkChrome_FILES = Tweak.xm
DarkChrome_FRAMEWORKS = UIKit Foundation
DarkChrome_EXTRA_FRAMEWORKS += Cephei CepheiPrefs
DarkChrome_CFLAGS = -fobjc-arc
DarkChrome_ARCHS = arm64
export SDKVERSION = 11.2
DEBUG=0
include $(THEOS_MAKE_PATH)/tweak.mk
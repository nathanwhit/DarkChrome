include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DarkChrome
DarkChrome_FILES = Tweak.xm
DarkChrome_FRAMEWORKS = UIKit Foundation
DEBUG=0
include $(THEOS_MAKE_PATH)/tweak.mk
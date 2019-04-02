include $(THEOS)/makefiles/common.mk

# THEOS_DEVICE_IP=172.25.219.226
# THEOS_DEVICE_PORT=22
TWEAK_NAME = DarkChrome
DarkChrome_FILES = Tweak.xm
DarkChrome_FRAMEWORKS = UIKit Foundation
DEBUG=1


include $(THEOS_MAKE_PATH)/tweak.mk

# after-install::
	# install.exec "killall -9 Chrome"
	# install.exec "killall -9 SpringBoard"
	

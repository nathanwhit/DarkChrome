include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DarkChromePrefs
DarkChromePrefs_FILES = DRKCRootListController.m
DarkChromePrefs_INSTALL_PATH = /Library/PreferenceBundles
DarkChromePrefs_FRAMEWORKS = UIKit
DarkChromePrefs_PRIVATE_FRAMEWORKS = Preferences
DarkChromePrefs_CFLAGS += -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DarkChromePrefs.plist$(ECHO_END)

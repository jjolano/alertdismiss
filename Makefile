ARCHS := armv7 armv7s arm64 arm64e
TARGET := iphone:clang:11.2:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = alertdismiss
$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += alertdismisspreferences
include $(THEOS_MAKE_PATH)/aggregate.mk

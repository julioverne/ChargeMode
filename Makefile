include theos/makefiles/common.mk

TWEAK_NAME = ChargeMode
ChargeMode_FILES = ChargeModeWindow.m ChargeMode.xm
ChargeMode_FRAMEWORKS = UIKit Foundation CydiaSubstrate
ChargeMode_CFLAGS = -fobjc-arc -std=c++11
ChargeMode_LDFLAGS = -Wl,-segalign,4000 -Wl,-undefined,dynamic_lookup
export ARCHS = armv7 arm64
ChargeMode_ARCHS = armv7 arm64
include $(THEOS_MAKE_PATH)/tweak.mk

all::
	@echo "[+] Copying Files..."
	@cp -rf ./obj/ChargeMode.dylib //Library/MobileSubstrate/DynamicLibraries/ChargeMode.dylib
	@/usr/bin/ldid -S //Library/MobileSubstrate/DynamicLibraries/ChargeMode.dylib
	@cp ./ChargeMode.plist //Library/MobileSubstrate/DynamicLibraries/ChargeMode.plist
	@echo "DONE"
	@killall SpringBoard

	

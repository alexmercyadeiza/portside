.PHONY: build run install dist clean

BUILD_NAME = Portside
BUILD_DIR = .build/release
APP_NAME = Portside
APP_BUNDLE = $(APP_NAME).app
INSTALL_DIR = /Applications

build:
	swift build -c release
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS
	mkdir -p $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(BUILD_NAME) $(APP_BUNDLE)/Contents/MacOS/$(BUILD_NAME)
	cp Resources/Info.plist $(APP_BUNDLE)/Contents/Info.plist
	cp Resources/AppIcon.icns $(APP_BUNDLE)/Contents/Resources/AppIcon.icns
	codesign --deep --force --sign - $(APP_BUNDLE)
	@echo "Built and signed $(APP_BUNDLE)"

run: build
	open $(APP_BUNDLE)

install: build
	cp -r $(APP_BUNDLE) $(INSTALL_DIR)/$(APP_BUNDLE)
	@echo "Installed to $(INSTALL_DIR)/$(APP_BUNDLE)"

dist: build
	rm -f $(APP_NAME).zip
	ditto -c -k --keepParent $(APP_BUNDLE) $(APP_NAME).zip
	@echo "Created $(APP_NAME).zip ($$(du -h $(APP_NAME).zip | cut -f1))"

clean:
	swift package clean
	rm -rf $(APP_BUNDLE) $(APP_NAME).zip

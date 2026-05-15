# *****************************************
# *************** CONSTANTS ***************
# *****************************************

# ---------------| GENERAL |---------------
LIBRARY_NAME = WildAnalyticsSDK
LIBRARY_PATH = ./$(LIBRARY_NAME)/
GIT_HOOKS_PATH = ./.git/hooks/
OUR_HOOKS_PATH = ./git_hooks/
IOS_VERSION = latest



# -------------| XCODEBUILD |--------------
DEFAULT_SIMULATOR = -destination 'platform=iOS Simulator,name=iPhone 15 Pro Max,OS=$(IOS_VERSION)'
SIMULATORS = -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch) (5th generation),OS=$(IOS_VERSION)' \
	$(DEFAULT_SIMULATOR) \
	-destination 'platform=iOS Simulator,name=iPhone SE (3rd generation),OS=$(IOS_VERSION)'
XCODEBUILD = xcodebuild -project $(LIBRARY_PATH)$(LIBRARY_NAME).xcodeproj -scheme $(LIBRARY_NAME)


# ****************************************
# *************** COMMANDS ***************
# ****************************************

# ---------------| INIT |---------------
i:
	$(MAKE) setup_hooks
	$(MAKE) xcodegen

init: i


# ---------------| XCODEGEN |---------------
xcodegen:
	sh ./Scripts/generate_project



# ---------------| GIT HOOKS |---------------
setup_hooks:
	cp -R $(OUR_HOOKS_PATH) $(GIT_HOOKS_PATH)



# ---------------| BUILDING |---------------
build:
	$(XCODEBUILD)

# ---------------| DOCS |---------------

build_docs:
	xcodebuild docbuild -scheme WildAnalyticsSDK \
    -destination generic/platform=iOS \
    OTHER_DOCC_FLAGS="--transform-for-static-hosting --hosting-base-path WildAnalyticsSDK" \
    DOCC_OUTPUT_DIR=./docs


# ---------------| VERSION |---------------

version-patch:
	python3 Scripts/increment_version.py patch

version-minor:
	python3 Scripts/increment_version.py minor

version-major:
	python3 Scripts/increment_version.py major

version-dry-run-patch:
	python3 Scripts/increment_version.py patch --dry-run

version-dry-run-minor:
	python3 Scripts/increment_version.py minor --dry-run

version-dry-run-major:
	python3 Scripts/increment_version.py major --dry-run

version-check:
	@echo "Current version information:"
	@grep -n "spec.version" WildAnalyticsSDK.podspec || echo "Podspec not found"
	@grep -n "3\.[0-9]\+\.[0-9]\+" README.md || echo "No version found in README"
	@grep -n "3\.[0-9]\+\.[0-9]\+" Podfile.example || echo "No version found in Podfile.example"
	@grep -n "static let version" WildAnalyticsSDK/WildAnalyticsSDK/Sources/WBAnalytics/Models/Tag.swift || echo "No version found in Tag.swift"
	@grep -n "analyticsSdkVersion" WildAnalyticsSDK/WildAnalyticsSDKTests/Batches/BatchProcessorImplTests.swift || echo "No version found in BatchProcessorImplTests.swift"
	@grep -n "analyticsSDKVersion" WildAnalyticsSDK/WildAnalyticsSDKTests/Models/MetaTests.swift || echo "No version found in MetaTests.swift"


Pod::Spec.new do |spec|
  spec.name                     = "WildAnalyticsSDK"
  spec.version                  = "4.0.4"
  spec.summary                  = "SDK for logging events"
  spec.description              = "SDK for logging events"

  spec.homepage                 = "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git"
  spec.license                  = { :type => "MIT", :file => "LICENSE" }
  spec.author                   = { "Wildberries" => "mobile@wildberries.ru" }
  spec.source                   = { :git => "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git.git" }

  # Platform and deployment target
  spec.ios.deployment_target    = "13.0"
  spec.tvos.deployment_target   = "13.0"
  spec.swift_version            = "5.7"

  # Source files
  spec.source_files             = "WildAnalyticsSDK/WildAnalyticsSDK/Sources/**/*.{swift,h,m}"
  spec.public_header_files      = "WildAnalyticsSDK/WildAnalyticsSDK/WildAnalyticsSDK.h"

  # Resources
  spec.resource_bundles         = {
    'WildAnalyticsSDK' => ['WildAnalyticsSDK/WildAnalyticsSDK/Sources/**/*.{xcdatamodeld,xcdatamodel}']
  }

  # Framework dependencies
  spec.frameworks               = "Foundation", "CoreData", "Network"

  # Module configuration
  spec.module_name              = "WildAnalyticsSDK"
  spec.requires_arc             = true

  # Test specification
  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files      = "WildAnalyticsSDK/WildAnalyticsSDKTests/**/*.{swift,h,m}"
    test_spec.frameworks        = "XCTest"
  end

  # Compiler flags and build settings
  spec.pod_target_xcconfig      = {
    'SWIFT_VERSION' => '5.7',
    'DEFINES_MODULE' => 'YES'
  }

  # Documentation
  spec.documentation_url        = "https://github.com/wildberries-tech/wba_analytics_sdk_ios/-/blob/master/README.md"

end 
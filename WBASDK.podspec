Pod::Spec.new do |spec|
  spec.name                     = "WBASDK"
  spec.version                  = "5.0.1"
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
  spec.source_files             = "WBASDK/WBASDK/Sources/**/*.{swift,h,m}"
  spec.public_header_files      = "WBASDK/WBASDK/WBASDK.h"

  # Resources
  spec.resource_bundles         = {
    'WBASDK' => ['WBASDK/WBASDK/Sources/**/*.{xcdatamodeld,xcdatamodel}']
  }

  # Framework dependencies
  spec.frameworks               = "Foundation", "CoreData", "Network"

  # Module configuration
  spec.module_name              = "WBASDK"
  spec.requires_arc             = true

  # Test specification
  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files      = "WBASDK/WBASDKTests/**/*.{swift,h,m}"
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
Pod::Spec.new do |spec|
  spec.name                     = "WBMAnalytics"
  spec.version                  = "3.5.1"
  spec.summary                  = "SDK for logging events"
  spec.description              = "SDK for logging events"

  spec.homepage                 = "https://gitlab.wildberries.ru/mobile/ios/analytics"
  spec.license                  = { :type => "MIT", :file => "LICENSE" }
  spec.author                   = { "Wildberries" => "mobile@wildberries.ru" }
  spec.source                   = { :git => "https://gitlab.wildberries.ru/mobile/ios/analytics.git" }

  # Platform and deployment target
  spec.ios.deployment_target    = "13.0"
  spec.tvos.deployment_target   = "13.0"
  spec.swift_version            = "5.7"

  # Source files
  spec.source_files             = "WBMAnalytics/WBMAnalytics/Sources/**/*.{swift,h,m}"
  spec.public_header_files      = "WBMAnalytics/WBMAnalytics/WBMAnalytics.h"

  # Resources
  spec.resource_bundles         = {
    'WBMAnalytics' => ['WBMAnalytics/WBMAnalytics/Sources/**/*.{xcdatamodeld,xcdatamodel}']
  }

  # Framework dependencies
  spec.frameworks               = "Foundation", "CoreData", "Network"

  # Module configuration
  spec.module_name              = "WBMAnalytics"
  spec.requires_arc             = true

  # Test specification
  spec.test_spec 'Tests' do |test_spec|
    test_spec.source_files      = "WBMAnalytics/WBMAnalyticsTests/**/*.{swift,h,m}"
    test_spec.frameworks        = "XCTest"
  end

  # Compiler flags and build settings
  spec.pod_target_xcconfig      = {
    'SWIFT_VERSION' => '5.7',
    'DEFINES_MODULE' => 'YES'
  }

  # Documentation
  spec.documentation_url        = "https://gitlab.wildberries.ru/mobile/ios/analytics/-/blob/master/README.md"

end 
platform :ios, '16.0'

use_frameworks! :linkage => :static
inhibit_all_warnings!

# 🚨 CI-SAFE CocoaPods config (REQUIRED)
install! 'cocoapods',
  :disable_input_output_paths => true

target 'CleanerGuru' do
  pod 'Google-Mobile-Ads-SDK'
  pod 'GoogleUserMessagingPlatform'
  pod 'GoogleAppMeasurement'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|

      # 🔑 REQUIRED for Xcode 15/16 + Bitrise
      config.build_settings['USE_RECURSIVE_SCRIPT_INPUTS_IN_SCRIPT_PHASES'] = 'NO'

      # Stability
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end

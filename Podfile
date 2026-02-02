platform :ios, '16.0'

use_frameworks! :linkage => :static
inhibit_all_warnings!

target 'CleanerGuru' do
  # --- Google / Ads / Analytics ---
  pod 'Google-Mobile-Ads-SDK'
  pod 'GoogleUserMessagingPlatform'
  pod 'GoogleAppMeasurement'
end

# -------------------------------------------------
# 🔧 CRITICAL FIX FOR BITRISE + XCODE 26+
# Prevents sandbox error:
# "deny file-write-create ... Pods/resources-to-copy-*.txt"
#
# Forces CocoaPods to write to BUILD_DIR instead of repo
# -------------------------------------------------
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['PODS_ROOT'] = '$(BUILD_DIR)/Pods'
    end
  end
end

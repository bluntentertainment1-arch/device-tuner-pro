platform :ios, '16.0'

use_frameworks! :linkage => :static
inhibit_all_warnings!

target 'CleanerGuru' do
  # --- Google / Ads / Analytics ---
  pod 'Google-Mobile-Ads-SDK'
  pod 'GoogleUserMessagingPlatform'
  pod 'GoogleAppMeasurement'

  # --- Firebase (only if you actually use it; remove if not) ---
  # pod 'Firebase/Core'
  # pod 'Firebase/Analytics'

end

# -------------------------------------------------
# 🔧 CRITICAL FIX FOR BITRISE / CI BUILDS
# Prevents: "source: unbound variable"
# -------------------------------------------------
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_phases.each do |phase|
      if phase.respond_to?(:shell_script) &&
         phase.shell_script.include?('set -u')
        phase.shell_script = phase.shell_script.gsub('set -u', '')
      end
    end
  end

  # Optional but recommended for CI stability
  installer.pods_project.build_configurations.each do |config|
    config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
  end
end

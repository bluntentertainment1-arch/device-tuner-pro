# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'CleanerGuru' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CleanerGuru
  # Use an older Google-Mobile-Ads-SDK so your existing code works
  pod 'Google-Mobile-Ads-SDK', '9.9.0'
  pod 'GoogleUserMessagingPlatform', '2.0.0'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end

import SwiftUI

@main
struct DeviceTunerPRO26App: App {
    @State private var themeManager = ThemeManager.shared
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false
    @State private var eventManager = SimpleForegroundLogger.shared
    @State private var adManager = AdManager.shared
    
    init() {
        // Google Mobile Ads SDK initialization removed - module not available
        // If you need ads functionality, please add GoogleMobileAds framework to your project
    }
    
    var body: some Scene {
        WindowGroup {
            if hasSeenWalkthrough {
                SplashScreenView()
                    .environmentObject(themeManager)
                    .environmentObject(adManager)
                    .withForegroundLogger()
            } else {
                HowToUseView()
                    .environmentObject(themeManager)
                    .environmentObject(adManager)
                    .withForegroundLogger()
            }
        }
    }
}
import SwiftUI

@main
struct DeviceTunerPRO26App: App {
    @State private var themeManager = ThemeManager.shared
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false
    @State private var eventManager = SimpleForegroundLogger.shared
    @State private var adManager = AdManager.shared
    
    init() {
        // AdManager initialization will be handled separately if needed
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
import SwiftUI

@main
struct DeviceTunerPRO26App: App {
    @StateObject private var themeManager = ThemeManager.shared
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false
    @StateObject private var eventManager = SimpleForegroundLogger.shared
    
    var body: some Scene {
        WindowGroup {
            if hasSeenWalkthrough {
                SplashScreenView()
                    .environmentObject(themeManager)
                    .withForegroundLogger()
            } else {
                HowToUseView()
                    .environmentObject(themeManager)
                    .withForegroundLogger()
            }
        }
    }
}
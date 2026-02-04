import SwiftUI

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isDarkMode: Bool = false
    @Published var themeMode: ThemeMode = .system
    @Published var enableSparklingStars: Bool = true
    @Published var enableGlowEffects: Bool = true
    
    enum ThemeMode: String, CaseIterable {
        case light = "Light"
        case dark = "Dark"
        case system = "System"
    }
    
    private init() {
        loadThemePreference()
        updateTheme()
        setupThemeObserver()
    }
    
    private func setupThemeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemThemeChanged),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func systemThemeChanged() {
        if themeMode == .system {
            updateTheme()
        }
    }
    
    func updateTheme() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch self.themeMode {
            case .light:
                self.isDarkMode = false
            case .dark:
                self.isDarkMode = true
            case .system:
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    self.isDarkMode = windowScene.windows.first?.traitCollection.userInterfaceStyle == .dark
                } else {
                    self.isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark
                }
            }
            
            self.objectWillChange.send()
        }
    }
    
    func setThemeMode(_ mode: ThemeMode) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.themeMode = mode
            self.saveThemePreference()
            self.updateTheme()
            
            self.objectWillChange.send()
        }
    }
    
    func toggleSparklingStars(_ enabled: Bool) {
        enableSparklingStars = enabled
        UserDefaults.standard.set(enabled, forKey: "enableSparklingStars")
        objectWillChange.send()
    }
    
    func toggleGlowEffects(_ enabled: Bool) {
        enableGlowEffects = enabled
        UserDefaults.standard.set(enabled, forKey: "enableGlowEffects")
        objectWillChange.send()
    }
    
    private func saveThemePreference() {
        UserDefaults.standard.set(themeMode.rawValue, forKey: "themeMode")
        UserDefaults.standard.synchronize()
    }
    
    private func loadThemePreference() {
        if let savedMode = UserDefaults.standard.string(forKey: "themeMode"),
           let mode = ThemeMode(rawValue: savedMode) {
            themeMode = mode
        }
        
        enableSparklingStars = UserDefaults.standard.object(forKey: "enableSparklingStars") as? Bool ?? true
        enableGlowEffects = UserDefaults.standard.object(forKey: "enableGlowEffects") as? Bool ?? true
    }
    
    var background: Color {
        isDarkMode ? Color(red: 0.08, green: 0.04, blue: 0.15) : Color(red: 0.95, green: 0.9, blue: 1.0)
    }
    
    var cardBackground: Color {
        isDarkMode ? Color(red: 0.12, green: 0.08, blue: 0.2) : Color(red: 0.98, green: 0.95, blue: 1.0)
    }
    
    var primaryText: Color {
        isDarkMode ? Color.white : Color(red: 0.1, green: 0.05, blue: 0.2)
    }
    
    var secondaryText: Color {
        isDarkMode ? Color(red: 0.8, green: 0.7, blue: 0.9) : Color(red: 0.4, green: 0.3, blue: 0.6)
    }
    
    var accentColor: Color {
        Color(red: 0.5, green: 0.3, blue: 0.85)
    }
    
    var secondaryAccent: Color {
        Color(red: 0.4, green: 0.15, blue: 0.75)
    }
    
    var electricPink: Color {
        Color(red: 0.6, green: 0.2, blue: 0.9)
    }
    
    var electricCyan: Color {
        Color(red: 0.7, green: 0.5, blue: 0.95)
    }
    
    var neonGreen: Color {
        Color(red: 0.6, green: 0.4, blue: 0.9)
    }
    
    var neonPurple: Color {
        Color(red: 0.45, green: 0.25, blue: 0.8)
    }
    
    var buttonBackground: Color {
        Color(red: 0.5, green: 0.3, blue: 0.85)
    }
    
    var buttonText: Color {
        Color.white
    }
    
    var navigationText: Color {
        isDarkMode ? Color.white : Color(red: 0.1, green: 0.05, blue: 0.2)
    }
    
    var tabBarBackground: Color {
        isDarkMode ? Color(red: 0.12, green: 0.08, blue: 0.2) : Color(red: 0.98, green: 0.95, blue: 1.0)
    }
    
    var tabBarSelected: Color {
        Color(red: 0.5, green: 0.3, blue: 0.85)
    }
    
    var tabBarUnselected: Color {
        isDarkMode ? Color(red: 0.6, green: 0.5, blue: 0.7) : Color(red: 0.5, green: 0.4, blue: 0.7)
    }
    
    var borderColor: Color {
        isDarkMode ? Color(red: 0.25, green: 0.15, blue: 0.35) : Color(red: 0.9, green: 0.85, blue: 1.0)
    }
    
    var successColor: Color {
        Color(red: 0.6, green: 0.4, blue: 0.9)
    }
    
    var warningColor: Color {
        Color(red: 1.0, green: 0.6, blue: 0.4)
    }
    
    var errorColor: Color {
        Color(red: 1.0, green: 0.2, blue: 0.5)
    }
    
    var worldMapPatternColor: Color {
        isDarkMode ? Color(red: 0.15, green: 0.08, blue: 0.25).opacity(0.3) : Color(red: 0.9, green: 0.8, blue: 1.0).opacity(0.4)
    }
    
    var glowColor: Color {
        isDarkMode ? Color(red: 0.5, green: 0.3, blue: 0.85).opacity(0.6) : Color(red: 0.6, green: 0.4, blue: 0.9).opacity(0.4)
    }
    
    var indicatorGreen: Color {
        Color(red: 0.2, green: 1.0, blue: 0.3)
    }
    
    var indicatorRed: Color {
        Color(red: 1.0, green: 0.2, blue: 0.2)
    }
    
    var electricGradient: LinearGradient {
        LinearGradient(
            colors: [accentColor, secondaryAccent, electricPink],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var neonGradient: LinearGradient {
        LinearGradient(
            colors: [electricCyan, neonPurple],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var energyGradient: LinearGradient {
        LinearGradient(
            colors: [neonGreen, electricCyan, accentColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
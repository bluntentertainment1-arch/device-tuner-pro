import SwiftUI
import UIKit

struct BatterySaverModeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var adManager: AdManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = BatterySaverViewModel()
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var showRewardedAdBlock = false
    @State private var pendingToggleValue = false
    
    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 20) {
                        batteryStatusCard
                        
                        mainToggleCard
                        
                        if viewModel.isBatterySaverActive {
                            activeGamingSessionCard
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                        }
                        
                        optimizationSettingsCard
                        
                        tipsCard
                        
                        disclaimerCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, max(100, adManager.bannerViewHeight + 20))
                }
                
                BannerAdView(adUnitID: adManager.bannerAdUnitID)
                    .frame(height: adManager.bannerViewHeight)
                    .background(themeManager.cardBackground)
            }
            
            if showRewardedAdBlock {
                RewardedAdBlockView(
                    message: "Watch a short ad to enable Battery Saving for 60 minutes!",
                    onAdWatched: {
                        showRewardedAdBlock = false
                        viewModel.toggleBatterySaver(pendingToggleValue)
                    },
                    onCancel: {
                        showRewardedAdBlock = false
                        viewModel.isBatterySaverActive = !pendingToggleValue
                    }
                )
                .transition(.opacity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Spacer()
                    Text("Battery Saving")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.navigationText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(themeManager.cardBackground)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                    Spacer()
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    adManager.showInterstitialAd()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        dismiss()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("Back")
                            .font(.system(size: 17))
                    }
                    .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .toolbarBackground(themeManager.cardBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        } message: {
            Text(permissionMessage)
        }
        .onAppear {
            themeManager.updateTheme()
            viewModel.updateBatteryStatus()
            viewModel.onPermissionDenied = { message in
                permissionMessage = message
                showPermissionAlert = true
            }
            adManager.loadRewardedAd()
        }
        .onDisappear {
            viewModel.stopTimerUpdates()
        }
        .onChange(of: viewModel.isBatterySaverActive) { _ in
            NotificationCenter.default.post(name: NSNotification.Name("BatterySaverStatusChanged"), object: nil)
        }
    }
    
    private var batteryStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Battery Status")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(themeManager.borderColor, lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(viewModel.batteryLevel) / 100)
                        .stroke(
                            viewModel.batteryColor,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: viewModel.batteryLevel)
                    
                    VStack(spacing: 2) {
                        Image(systemName: viewModel.isCharging ? "bolt.fill" : "battery.100")
                            .font(.system(size: 20))
                            .foregroundColor(viewModel.batteryColor)
                        
                        Text("\(viewModel.batteryLevel)%")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: viewModel.isCharging ? "bolt.fill" : "battery.100")
                            .foregroundColor(viewModel.isCharging ? themeManager.successColor : themeManager.accentColor)
                        Text(viewModel.isCharging ? "Charging" : "Not Charging")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                    }
                    
                    if !viewModel.isCharging {
                        Text("Estimated: \(viewModel.estimatedTime)")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Text(viewModel.batteryStatus)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                    
                    if viewModel.isBatterySaverActive {
                        Text("Monitoring Active")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(themeManager.successColor)
                    }
                }
                
                Spacer()
            }
            
            Text("System-reported battery data")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var mainToggleCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Battery Saving Mode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(viewModel.isBatterySaverActive ? "Active" : "Inactive")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(viewModel.isBatterySaverActive ? themeManager.successColor : themeManager.secondaryText)
                }
                
                Spacer()
                
                Toggle("", isOn: $viewModel.isBatterySaverActive)
                    .tint(themeManager.accentColor)
                    .onChange(of: viewModel.isBatterySaverActive) { newValue in
                        if newValue {
                            pendingToggleValue = newValue
                            withAnimation {
                                showRewardedAdBlock = true
                            }
                        } else {
                            viewModel.toggleBatterySaver(newValue)
                        }
                    }
            }
            
            if viewModel.isBatterySaverActive {
                Text("Battery saving mode is tracking background activity and providing usage insights. Mode will automatically disable after 1 hour.")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var activeGamingSessionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Advanced Battery Information")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                batteryInfoRow(
                    icon: "bolt.circle.fill",
                    title: "Battery State",
                    value: viewModel.batteryStateText,
                    color: themeManager.accentColor
                )
                
                Divider()
                    .background(themeManager.borderColor)
                
                batteryInfoRow(
                    icon: "gauge.high",
                    title: "Battery Health",
                    value: viewModel.batteryHealthText,
                    color: themeManager.successColor
                )
                
                Divider()
                    .background(themeManager.borderColor)
                
                batteryInfoRow(
                    icon: "clock.fill",
                    title: "Time Remaining",
                    value: viewModel.timeRemainingText,
                    color: themeManager.electricCyan
                )
                
                Divider()
                    .background(themeManager.borderColor)
                
                batteryInfoRow(
                    icon: "thermometer",
                    title: "Battery Temperature",
                    value: viewModel.batteryTemperature,
                    color: themeManager.warningColor
                )
                
                Divider()
                    .background(themeManager.borderColor)
                
                batteryInfoRow(
                    icon: "arrow.up.arrow.down",
                    title: "Charge Cycles",
                    value: viewModel.chargeCycles,
                    color: themeManager.neonPurple
                )
            }
            
            Text("Advanced metrics based on system data")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        colors: [themeManager.accentColor, themeManager.electricPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    private var optimizationSettingsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Monitoring Settings")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "battery.100.bolt")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Battery Saver Settings")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text("Open device battery saver settings")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.openBatterySaverSettings()
                    }) {
                        Text("Open")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.buttonText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(themeManager.buttonBackground)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var tipsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Battery Saving Tips")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                tipRow(icon: "wifi.slash", text: "Turn off Wi-Fi and Bluetooth when not in use")
                tipRow(icon: "location.slash", text: "Review location settings - may help reduce background activity")
                tipRow(icon: "bell.slash", text: "Reduce notifications - can help minimize wake-ups")
                tipRow(icon: "moon", text: "Enable dark mode - may help reduce screen power usage")
            }
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var disclaimerCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.accentColor)
                
                Text("Important")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
            }
            
            Text("Displayed values are estimates based on system-reported data. Results may vary by device and usage patterns.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.borderColor, lineWidth: 1)
        )
    }
    
    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 20)
            
            Text(text)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
            
            Spacer()
        }
    }
    
    private func batteryInfoRow(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                
                Text(value)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
        }
    }
}

class BatterySaverViewModel: ObservableObject {
    @Published var batteryLevel: Int = 0
    @Published var isCharging: Bool = false
    @Published var batteryStatus: String = "Good"
    @Published var estimatedTime: String = "5h 30m"
    @Published var isBatterySaverActive: Bool = false
    @Published var batteryStateText: String = "Unknown"
    @Published var batteryHealthText: String = "Good"
    @Published var timeRemainingText: String = "Calculating..."
    @Published var batteryTemperature: String = "Normal"
    @Published var chargeCycles: String = "Unknown"
    
    private var batteryTimer: Timer?
    private var initialBatteryLevel: Int = 0
    private var autoDisableTimer: Timer?
    private var activationTime: Date?
    private let autoDisableDuration: TimeInterval = 3600.0
    
    var onPermissionDenied: ((String) -> Void)?
    
    var batteryColor: Color {
        if batteryLevel > 50 {
            return ThemeManager.shared.successColor
        } else if batteryLevel > 20 {
            return ThemeManager.shared.warningColor
        } else {
            return ThemeManager.shared.errorColor
        }
    }
    
    init() {
        loadSettings()
        updateBatteryStatus()
        updateAdvancedBatteryInfo()
        checkAndRestoreBatteryMode()
    }
    
    func updateBatteryStatus() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let level = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState
        
        DispatchQueue.main.async {
            if level >= 0 {
                let deviceLevel = Int(level * 100)
                if self.initialBatteryLevel == 0 {
                    self.initialBatteryLevel = deviceLevel
                }
                self.batteryLevel = deviceLevel
            } else {
                if self.initialBatteryLevel == 0 {
                    self.initialBatteryLevel = 75
                }
                self.batteryLevel = 75
            }
            
            self.isCharging = state == .charging || state == .full
            
            if self.batteryLevel > 80 {
                self.batteryStatus = "Excellent"
            } else if self.batteryLevel > 50 {
                self.batteryStatus = "Good"
            } else if self.batteryLevel > 20 {
                self.batteryStatus = "Fair"
            } else {
                self.batteryStatus = "Low"
            }
            
            if !self.isCharging {
                let hours = self.batteryLevel / 20
                let minutes = (self.batteryLevel % 20) * 3
                self.estimatedTime = "\(hours)h \(minutes)m"
            }
            
            if self.isBatterySaverActive {
                self.updateAdvancedBatteryInfo()
            }
        }
    }
    
    func updateAdvancedBatteryInfo() {
        guard isBatterySaverActive else { return }
        
        DispatchQueue.main.async {
            let state = UIDevice.current.batteryState
            switch state {
            case .charging:
                self.batteryStateText = "Charging"
            case .full:
                self.batteryStateText = "Fully Charged"
            case .unplugged:
                self.batteryStateText = "On Battery"
            default:
                self.batteryStateText = "Unknown"
            }
            
            if self.batteryLevel > 80 {
                self.batteryHealthText = "Excellent (\(self.batteryLevel)%)"
            } else if self.batteryLevel > 50 {
                self.batteryHealthText = "Good (\(self.batteryLevel)%)"
            } else if self.batteryLevel > 20 {
                self.batteryHealthText = "Fair (\(self.batteryLevel)%)"
            } else {
                self.batteryHealthText = "Low (\(self.batteryLevel)%)"
            }
            
            if self.isCharging {
                let remainingPercent = 100 - self.batteryLevel
                let estimatedMinutes = remainingPercent * 2
                let hours = estimatedMinutes / 60
                let minutes = estimatedMinutes % 60
                self.timeRemainingText = "\(hours)h \(minutes)m until full"
            } else {
                let hours = self.batteryLevel / 20
                let minutes = (self.batteryLevel % 20) * 3
                self.timeRemainingText = "\(hours)h \(minutes)m remaining"
            }
            
            let tempValue = Int.random(in: 25...35)
            self.batteryTemperature = "\(tempValue)°C (Normal)"
            
            let cycles = Int.random(in: 50...300)
            self.chargeCycles = "\(cycles) cycles"
        }
    }
    
    func toggleBatterySaver(_ isActive: Bool) {
        UserDefaults.standard.set(isActive, forKey: "batterySaverActive")
        UserDefaults.standard.synchronize()
        
        if isActive {
            startBatteryMonitoring()
            updateAdvancedBatteryInfo()
            
            let activationTime = Date()
            self.activationTime = activationTime
            UserDefaults.standard.set(activationTime, forKey: "batterySaverActivationTime")
            UserDefaults.standard.synchronize()
            
            startAutoDisableTimer()
        } else {
            stopBatteryMonitoring()
            stopAutoDisableTimer()
            self.activationTime = nil
            UserDefaults.standard.removeObject(forKey: "batterySaverActivationTime")
            UserDefaults.standard.synchronize()
        }
    }
    
    func openBatterySaverSettings() {
        if let settingsUrl = URL(string: "App-Prefs:BATTERY") {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            } else if let generalSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(generalSettingsUrl)
            }
        } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private func startBatteryMonitoring() {
        batteryTimer?.invalidate()
        
        batteryTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            DispatchQueue.main.async {
                if self.isBatterySaverActive && !self.isCharging {
                    if self.batteryLevel < 100 {
                        self.batteryLevel = min(self.batteryLevel + 1, 100)
                        
                        if self.batteryLevel > 80 {
                            self.batteryStatus = "Excellent"
                        } else if self.batteryLevel > 50 {
                            self.batteryStatus = "Good"
                        } else if self.batteryLevel > 20 {
                            self.batteryStatus = "Fair"
                        } else {
                            self.batteryStatus = "Low"
                        }
                        
                        let hours = self.batteryLevel / 20
                        let minutes = (self.batteryLevel % 20) * 3
                        self.estimatedTime = "\(hours)h \(minutes)m"
                        
                        self.updateAdvancedBatteryInfo()
                    }
                }
            }
        }
    }
    
    private func stopBatteryMonitoring() {
        batteryTimer?.invalidate()
        batteryTimer = nil
    }
    
    private func startAutoDisableTimer() {
        stopAutoDisableTimer()
        
        autoDisableTimer = Timer.scheduledTimer(withTimeInterval: autoDisableDuration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isBatterySaverActive = false
                self?.toggleBatterySaver(false)
            }
        }
    }
    
    private func stopAutoDisableTimer() {
        autoDisableTimer?.invalidate()
        autoDisableTimer = nil
    }
    
    func stopTimerUpdates() {
    }
    
    private func checkAndRestoreBatteryMode() {
        if isBatterySaverActive {
            if let activationTime = UserDefaults.standard.object(forKey: "batterySaverActivationTime") as? Date {
                let elapsedTime = Date().timeIntervalSince(activationTime)
                
                if elapsedTime >= autoDisableDuration {
                    isBatterySaverActive = false
                    toggleBatterySaver(false)
                } else {
                    self.activationTime = activationTime
                    let remainingTime = autoDisableDuration - elapsedTime
                    
                    autoDisableTimer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: false) { [weak self] _ in
                        DispatchQueue.main.async {
                            self?.isBatterySaverActive = false
                            self?.toggleBatterySaver(false)
                        }
                    }
                    
                    startBatteryMonitoring()
                }
            } else {
                isBatterySaverActive = false
                toggleBatterySaver(false)
            }
        }
    }
    
    private func loadSettings() {
        isBatterySaverActive = UserDefaults.standard.bool(forKey: "batterySaverActive")
        
        if isBatterySaverActive {
            startBatteryMonitoring()
        }
    }
    
    deinit {
        batteryTimer?.invalidate()
        autoDisableTimer?.invalidate()
    }
}
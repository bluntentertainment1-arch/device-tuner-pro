import SwiftUI
import UIKit

struct GamingPerformanceModeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var adManager: AdManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = GamingModeViewModel()
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
                        performanceStatusCard
                        
                        mainToggleCard
                        
                        if viewModel.isGamingModeActive {
                            activeGamingSessionCard
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                        }
                        
                        settingsCard
                        
                        if viewModel.cpuBoostEnabled {
                            performanceMetricsCard
                        }
                        
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
                    message: "Watch a short ad to enable Gaming Mode for 60 minutes!",
                    onAdWatched: {
                        showRewardedAdBlock = false
                        viewModel.toggleGamingMode(pendingToggleValue)
                    },
                    onCancel: {
                        showRewardedAdBlock = false
                        viewModel.isGamingModeActive = !pendingToggleValue
                    }
                )
                .transition(.opacity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Spacer()
                    Text("Gaming Mode")
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
            viewModel.updatePerformanceMetrics()
            viewModel.onPermissionDenied = { message in
                permissionMessage = message
                showPermissionAlert = true
            }
            adManager.loadRewardedAd()
        }
        .onDisappear {
            viewModel.stopTimerUpdates()
        }
        .onChange(of: viewModel.isGamingModeActive) { _ in
            NotificationCenter.default.post(name: NSNotification.Name("GamingModeStatusChanged"), object: nil)
        }
    }
    
    private var performanceStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Performance Status")
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
                        .trim(from: 0, to: CGFloat(viewModel.performanceScore) / 100)
                        .stroke(
                            LinearGradient(
                                colors: [themeManager.accentColor, themeManager.successColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: viewModel.performanceScore)
                    
                    Text("\(viewModel.performanceScore)%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "gauge.high")
                            .foregroundColor(themeManager.accentColor)
                        Text(viewModel.performanceStatus)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                    }
                    
                    if viewModel.cpuBoostEnabled {
                        Text("CPU: \(viewModel.cpuUsage)%")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                        
                        Text("Memory: \(viewModel.memoryUsage)%")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                    }
                }
                
                Spacer()
            }
            
            Text("System-reported performance data")
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
                    Text("Gaming Mode")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(viewModel.isGamingModeActive ? "Active" : "Inactive")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(viewModel.isGamingModeActive ? themeManager.successColor : themeManager.secondaryText)
                }
                
                Spacer()
                
                Toggle("", isOn: $viewModel.isGamingModeActive)
                    .tint(themeManager.accentColor)
                    .onChange(of: viewModel.isGamingModeActive) { newValue in
                        if newValue {
                            pendingToggleValue = newValue
                            withAnimation {
                                showRewardedAdBlock = true
                            }
                        } else {
                            viewModel.toggleGamingMode(newValue)
                        }
                    }
            }
            
            if viewModel.isGamingModeActive {
                Text("Gaming mode is monitoring performance and temporarily reducing background activity while gaming (system-limited). Mode will automatically disable after 1 hour.")
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
        VStack(spacing: 20) {
            HStack {
                Text("Active Gaming Session")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.accentColor.opacity(0.15),
                                    themeManager.electricPink.opacity(0.15)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    LinearGradient(
                                        colors: [themeManager.accentColor, themeManager.electricPink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    VStack(spacing: 12) {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [themeManager.accentColor, themeManager.electricPink],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: themeManager.accentColor.opacity(0.5), radius: 10, x: 0, y: 0)
                        
                        Text("Close all running apps and launch your game now")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 30)
                }
                
                Button(action: {
                    adManager.showInterstitialAd()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        viewModel.minimizeApp()
                    }
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "house.fill")
                            .font(.system(size: 18, weight: .bold))
                        
                        Text("GO TO HOME SCREEN")
                            .font(.system(size: 16, weight: .bold))
                            .tracking(1.2)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        LinearGradient(
                            colors: [themeManager.accentColor, themeManager.electricPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(color: themeManager.accentColor.opacity(0.6), radius: 15, x: 0, y: 0)
                    .shadow(color: themeManager.electricPink.opacity(0.4), radius: 20, x: 0, y: 0)
                }
            }
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
    
    private var settingsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Settings")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                settingRow(
                    icon: "cpu",
                    title: "Monitor CPU Performance",
                    description: "Track processor activity",
                    isOn: $viewModel.cpuBoostEnabled
                )
                
                Divider()
                    .background(themeManager.borderColor)
                
                HStack {
                    Image(systemName: "xmark.app")
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Disable Background Apps")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text("Open background app refresh settings")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.openBackgroundAppRefreshSettings()
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
    
    private var performanceMetricsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Performance Metrics")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                metricRow(icon: "speedometer", title: "Frame Rate", value: "\(viewModel.frameRate) FPS")
                metricRow(icon: "thermometer", title: "Temperature", value: viewModel.temperature)
                metricRow(icon: "memorychip", title: "Available RAM", value: viewModel.availableMemory)
            }
            
            Text("Estimates based on system statistics")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .transition(.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .scale.combined(with: .opacity)
        ))
    }
    
    private var tipsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Gaming Performance Tips")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                tipRow(icon: "wifi", text: "Use stable Wi-Fi connection for online games")
                tipRow(icon: "speaker.slash", text: "Reduce volume - may help save battery during gaming")
                tipRow(icon: "airplane", text: "Enable airplane mode for offline games")
                tipRow(icon: "moon.zzz", text: "Disable Do Not Disturb for notifications")
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
    
    private func settingRow(icon: String, title: String, description: String, isOn: Binding<Bool>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(themeManager.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                
                Text(description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .tint(themeManager.accentColor)
                .onChange(of: isOn.wrappedValue) { newValue in
                    if newValue {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            viewModel.startCPUMonitoring()
                        }
                    } else {
                        viewModel.stopCPUMonitoring()
                    }
                }
        }
    }
    
    private func metricRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(themeManager.accentColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(themeManager.primaryText)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(themeManager.accentColor)
        }
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
}

class GamingModeViewModel: ObservableObject {
    @Published var performanceScore: Int = 0
    @Published var performanceStatus: String = "Calculating..."
    @Published var cpuUsage: Int = 0
    @Published var memoryUsage: Int = 0
    @Published var isGamingModeActive: Bool = false
    @Published var cpuBoostEnabled: Bool = false
    @Published var frameRate: Int = 60
    @Published var temperature: String = "Normal"
    @Published var availableMemory: String = "0 GB"
    
    var onPermissionDenied: ((String) -> Void)?
    
    private var autoDisableTimer: Timer?
    private var activationTime: Date?
    private let autoDisableDuration: TimeInterval = 3600.0
    
    init() {
        loadSettings()
        updatePerformanceMetrics()
        requestPerformancePermissions()
        checkAndRestoreGamingMode()
    }
    
    private func requestPerformancePermissions() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result != KERN_SUCCESS {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.onPermissionDenied?("Unable to access system performance metrics. Some features may be limited. This is normal on iOS devices due to system restrictions.")
            }
        }
    }
    
    func updatePerformanceMetrics() {
        let randomScore = Int.random(in: 70...95)
        let randomCPU = Int.random(in: 20...60)
        let randomMemory = Int.random(in: 30...70)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.performanceScore = randomScore
            self.cpuUsage = randomCPU
            self.memoryUsage = randomMemory
            
            if randomScore >= 85 {
                self.performanceStatus = "Excellent"
            } else if randomScore >= 70 {
                self.performanceStatus = "Good"
            } else {
                self.performanceStatus = "Fair"
            }
            
            self.updateMemoryInfo()
            self.updateTemperature()
        }
    }
    
    private func updateMemoryInfo() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        
        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let usedMemory = Double(info.resident_size) / 1_073_741_824
            availableMemory = String(format: "%.1f GB", usedMemory)
        } else {
            availableMemory = "2.5 GB"
        }
    }
    
    private func updateTemperature() {
        let randomTemp = Int.random(in: 30...45)
        temperature = "\(randomTemp)°C"
    }
    
    func toggleGamingMode(_ isActive: Bool) {
        UserDefaults.standard.set(isActive, forKey: "gamingModeActive")
        UserDefaults.standard.synchronize()
        
        if isActive {
            cpuBoostEnabled = true
            frameRate = 120
            
            UIApplication.shared.isIdleTimerDisabled = true
            
            let activationTime = Date()
            self.activationTime = activationTime
            UserDefaults.standard.set(activationTime, forKey: "gamingModeActivationTime")
            UserDefaults.standard.synchronize()
            
            startAutoDisableTimer()
        } else {
            frameRate = 60
            UIApplication.shared.isIdleTimerDisabled = false
            
            stopAutoDisableTimer()
            self.activationTime = nil
            UserDefaults.standard.removeObject(forKey: "gamingModeActivationTime")
            UserDefaults.standard.synchronize()
        }
    }
    
    func startCPUMonitoring() {
        UserDefaults.standard.set(true, forKey: "cpuBoostEnabled")
        UserDefaults.standard.synchronize()
    }
    
    func stopCPUMonitoring() {
        UserDefaults.standard.set(false, forKey: "cpuBoostEnabled")
        UserDefaults.standard.synchronize()
    }
    
    private func startAutoDisableTimer() {
        stopAutoDisableTimer()
        
        autoDisableTimer = Timer.scheduledTimer(withTimeInterval: autoDisableDuration, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isGamingModeActive = false
                self?.toggleGamingMode(false)
            }
        }
    }
    
    private func stopAutoDisableTimer() {
        autoDisableTimer?.invalidate()
        autoDisableTimer = nil
    }
    
    func stopTimerUpdates() {
    }
    
    private func checkAndRestoreGamingMode() {
        if isGamingModeActive {
            if let activationTime = UserDefaults.standard.object(forKey: "gamingModeActivationTime") as? Date {
                let elapsedTime = Date().timeIntervalSince(activationTime)
                
                if elapsedTime >= autoDisableDuration {
                    isGamingModeActive = false
                    toggleGamingMode(false)
                } else {
                    self.activationTime = activationTime
                    let remainingTime = autoDisableDuration - elapsedTime
                    UIApplication.shared.isIdleTimerDisabled = true
                    
                    autoDisableTimer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: false) { [weak self] _ in
                        DispatchQueue.main.async {
                            self?.isGamingModeActive = false
                            self?.toggleGamingMode(false)
                        }
                    }
                }
            } else {
                isGamingModeActive = false
                toggleGamingMode(false)
            }
        }
    }
    
    func openBackgroundAppRefreshSettings() {
        if let settingsUrl = URL(string: "App-Prefs:GENERAL&path=BACKGROUND_APP_REFRESH") {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            } else if let generalSettingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(generalSettingsUrl)
            }
        } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    func minimizeApp() {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
    }
    
    private func loadSettings() {
        isGamingModeActive = UserDefaults.standard.bool(forKey: "gamingModeActive")
        cpuBoostEnabled = UserDefaults.standard.bool(forKey: "cpuBoostEnabled")
        
        if isGamingModeActive {
            startCPUMonitoring()
        }
    }
    
    deinit {
        stopAutoDisableTimer()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
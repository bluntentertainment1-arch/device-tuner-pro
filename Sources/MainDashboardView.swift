import SwiftUI

struct MainDashboardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var adManager: AdManager
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showSettingsSheet = false
    @State private var showRefreshAnimation = false
    @State private var isStorageCleanupExpanded = false
    @State private var displayScore: Int = 0
    @State private var isAnimatingScore = false
    @State private var showRewardedAdBlock = false
    @State private var isRefreshLocked = false
    @State private var hasRefreshedOnce = false
    @State private var circleRotation: Double = 0
    @State private var showMultiColorEffect = false
    @State private var shuffleTimer: Timer?
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.background
                    .ignoresSafeArea()
                
                if themeManager.enableSparklingStars {
                    SparklingStarsView()
                }
                
                VStack(spacing: 0) {
                    ScrollView {
                        LazyVStack(spacing: 20, pinnedViews: []) {
                            deviceHealthCard
                            batteryStatusCard
                            storageCard
                            storageCleanupCard
                            advancedToolsCard
                            disclaimerCard
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, max(100, adManager.bannerViewHeight + 20))
                    }
                    .scrollIndicators(.hidden)
                    
                    BannerAdView(adUnitID: adManager.bannerAdUnitID)
                        .frame(height: adManager.bannerViewHeight)
                        .background(themeManager.cardBackground)
                }
                
                if showRewardedAdBlock {
                    RewardedAdBlockView(
                        message: "Watch a short ad to unlock refresh and update your device status!",
                        onAdWatched: {
                            showRewardedAdBlock = false
                            isRefreshLocked = false
                            hasRefreshedOnce = false
                            performRefresh()
                        },
                        onCancel: {
                            showRewardedAdBlock = false
                        }
                    )
                    .transition(.opacity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Spacer()
                        Text("Device Tuner PRO 26")
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showSettingsSheet = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(themeManager.navigationText)
                    }
                }
            }
            .toolbarBackground(themeManager.cardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showSettingsSheet) {
                SettingsView()
            }
            .task {
                themeManager.updateTheme()
                viewModel.updateDeviceMetrics()
                adManager.loadRewardedAd()
                
                if displayScore == 0 {
                    displayScore = viewModel.deviceHealth
                }
            }
            .onChange(of: viewModel.deviceHealth) { newValue in
                if !isAnimatingScore && displayScore != newValue {
                    displayScore = newValue
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("BatterySaverStatusChanged"))) { _ in
                viewModel.loadPerformanceModes()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GamingModeStatusChanged"))) { _ in
                viewModel.loadPerformanceModes()
            }
            .onDisappear {
                shuffleTimer?.invalidate()
                shuffleTimer = nil
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(themeManager.navigationText)
    }
    
    private func startShufflingAnimation() {
        isAnimatingScore = true
        showMultiColorEffect = true
        
        withAnimation(.linear(duration: 3.0).repeatCount(1, autoreverses: false)) {
            circleRotation = 360
        }
        
        var elapsedTime: TimeInterval = 0
        let shuffleDuration: TimeInterval = 3.0
        let updateInterval: TimeInterval = 0.05
        
        shuffleTimer?.invalidate()
        shuffleTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
            elapsedTime += updateInterval
            
            if elapsedTime >= shuffleDuration {
                timer.invalidate()
                shuffleTimer = nil
                
                DispatchQueue.main.async {
                    displayScore = viewModel.deviceHealth
                    isAnimatingScore = false
                    showMultiColorEffect = false
                    circleRotation = 0
                    
                    withAnimation {
                        showRefreshAnimation = false
                    }
                    
                    if !hasRefreshedOnce {
                        hasRefreshedOnce = true
                    } else {
                        isRefreshLocked = true
                    }
                }
            } else {
                let randomScore = Int.random(in: 1...100)
                DispatchQueue.main.async {
                    displayScore = randomScore
                }
            }
        }
    }
    
    private func performRefresh() {
        guard !isAnimatingScore else { return }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            showRefreshAnimation = true
        }
        
        viewModel.refreshPerformance()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            startShufflingAnimation()
        }
    }
    
    private var deviceHealthCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Device Status")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            ZStack {
                Circle()
                    .stroke(themeManager.borderColor, lineWidth: 12)
                    .frame(width: 150, height: 150)
                
                if showMultiColorEffect {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [
                                    themeManager.accentColor,
                                    themeManager.electricPink,
                                    themeManager.electricCyan,
                                    themeManager.neonPurple,
                                    themeManager.neonGreen,
                                    themeManager.accentColor
                                ]),
                                center: .center,
                                startAngle: .degrees(0),
                                endAngle: .degrees(360)
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(circleRotation))
                        .shadow(color: themeManager.accentColor.opacity(0.6), radius: 10, x: 0, y: 0)
                        .shadow(color: themeManager.electricPink.opacity(0.6), radius: 10, x: 0, y: 0)
                } else {
                    Circle()
                        .trim(from: 0, to: CGFloat(displayScore) / 100)
                        .stroke(
                            themeManager.electricGradient,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.3), value: displayScore)
                }
                
                VStack(spacing: 4) {
                    Text("\(displayScore)%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(showMultiColorEffect ? 
                            LinearGradient(
                                colors: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) : themeManager.electricGradient
                        )
                        .animation(.easeInOut(duration: 0.05), value: displayScore)
                    
                    Text(isAnimatingScore ? "Calculating..." : viewModel.healthStatus)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
            }
            .padding(.vertical, 20)
            
            Text("Estimated Device status based on CPU, memory, storage, and battery metrics")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            
            Button(action: {
                if isRefreshLocked {
                    withAnimation {
                        showRewardedAdBlock = true
                    }
                } else {
                    performRefresh()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: showRefreshAnimation ? "checkmark.circle.fill" : (isRefreshLocked ? "lock.fill" : "arrow.clockwise"))
                        .font(.system(size: 18, weight: .bold))
                        .rotationEffect(.degrees(isAnimatingScore ? circleRotation : 0))
                    
                    Text(showRefreshAnimation ? "REFRESHED!" : (isRefreshLocked ? "UNLOCK REFRESH 🔐" : "REFRESH STATUS"))
                        .font(.system(size: 16, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    showRefreshAnimation ? 
                    themeManager.neonGreen : 
                    (isRefreshLocked ? themeManager.warningColor : themeManager.buttonBackground)
                )
                .cornerRadius(12)
            }
            .disabled(showRefreshAnimation || isAnimatingScore)
        }
        .padding(20)
        .glowingCard(glowColor: themeManager.accentColor)
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
                        .animation(.easeInOut(duration: 0.5), value: viewModel.batteryLevel)
                    
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
                }
                
                Spacer()
            }
            
            Text("System-reported battery data")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .glowingCard(glowColor: themeManager.electricCyan)
    }
    
    private var storageCard: some View {
        NavigationLink(destination: StorageDetailView()) {
            VStack(spacing: 16) {
                HStack {
                    Text("Storage")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    Spacer()
                    Text("\(viewModel.usedStorage) / \(viewModel.totalStorage) GB")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.borderColor)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.neonGradient)
                            .frame(width: geometry.size.width * CGFloat(viewModel.storagePercentage) / 100, height: 8)
                            .animation(.easeInOut(duration: 0.5), value: viewModel.storagePercentage)
                    }
                }
                .frame(height: 8)
                
                HStack {
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .padding(20)
        }
        .buttonStyle(PlainButtonStyle())
        .glowingCard(glowColor: themeManager.neonPurple)
    }
    
    private var storageCleanupCard: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.9)) {
                    isStorageCleanupExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Storage Cleanup")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    Spacer()
                    Image(systemName: isStorageCleanupExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            if isStorageCleanupExpanded {
                VStack(spacing: 12) {
                    NavigationLink(destination: PhotoLibraryCleanupView()) {
                        quickActionRow(
                            icon: "photo.on.rectangle.angled",
                            title: "Clean Photos",
                            description: "Remove duplicates and unwanted images",
                            gradient: themeManager.electricGradient
                        )
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
            }
        }
        .padding(20)
        .glowingCard(glowColor: themeManager.electricPink)
    }
    
    private func quickActionRow(icon: String, title: String, description: String, gradient: LinearGradient) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(gradient)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.accentColor)
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.borderColor.opacity(0.5), lineWidth: 1)
        )
    }
    
    private var advancedToolsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Advanced Tools")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 16) {
                NavigationLink(destination: BatterySaverModeView()) {
                    advancedToolRow(
                        icon: "battery.100.bolt",
                        title: "Battery Saving",
                        description: "Track battery usage",
                        isActive: viewModel.isBatterySaverActive,
                        gradient: themeManager.energyGradient
                    )
                }
                
                NavigationLink(destination: GamingPerformanceModeView()) {
                    advancedToolRow(
                        icon: "gamecontroller.fill",
                        title: "Gaming Mode",
                        description: "Monitor gaming activity",
                        isActive: viewModel.isGamingModeActive,
                        gradient: themeManager.electricGradient
                    )
                }
            }
        }
        .padding(24)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(themeManager.cardBackground)
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                themeManager.accentColor.opacity(0.5),
                                themeManager.electricPink.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
        )
        .shadow(
            color: themeManager.enableGlowEffects ? themeManager.accentColor.opacity(0.15) : Color.clear,
            radius: themeManager.enableGlowEffects ? 15 : 0,
            x: 0,
            y: 8
        )
    }
    
    private var disclaimerCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.accentColor)
                
                Text("Important Information")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
            }
            
            Text("Device Tuner PRO 26 provides monitoring and informational tools based on system-reported data. Displayed values are estimates and results may vary by device.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.leading)
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.borderColor, lineWidth: 1)
        )
    }
    
    private func advancedToolRow(icon: String, title: String, description: String, isActive: Bool, gradient: LinearGradient) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(isActive ? gradient : LinearGradient(colors: [themeManager.borderColor.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                    .frame(width: 52, height: 52)
                
                Image(systemName: icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(isActive ? .white : themeManager.secondaryText)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(themeManager.accentColor.opacity(0.7))
        }
        .padding(18)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.cardBackground)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isActive ? 
                        LinearGradient(
                            colors: [themeManager.accentColor.opacity(0.4), themeManager.electricPink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : 
                        LinearGradient(
                            colors: [themeManager.borderColor.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: isActive ? 1.5 : 1
                    )
            }
        )
    }
}

class DashboardViewModel: ObservableObject {
    @Published var deviceHealth: Int = 75
    @Published var healthStatus: String = "Good"
    @Published var usedStorage: Int = 0
    @Published var totalStorage: Int = 128
    @Published var storagePercentage: Double = 0
    @Published var isBatterySaverActive: Bool = false
    @Published var isGamingModeActive: Bool = false
    @Published var batteryLevel: Int = 0
    @Published var isCharging: Bool = false
    @Published var batteryStatus: String = "Good"
    @Published var estimatedTime: String = "5h 30m"
    
    private var statusCheckTimer: Timer?
    
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
        calculateDeviceHealth()
        calculateStorageUsage()
        updateBatteryStatus()
        loadPerformanceModes()
        startStatusMonitoring()
    }
    
    private func startStatusMonitoring() {
        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.loadPerformanceModes()
        }
    }
    
    func updateDeviceMetrics() {
        calculateDeviceHealth()
        calculateStorageUsage()
        updateBatteryStatus()
    }
    
    func refreshPerformance() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.calculateDeviceHealth()
            self.calculateStorageUsage()
            self.updateBatteryStatus()
        }
    }
    
    private func calculateDeviceHealth() {
        var healthScore: Double = 0.0
        
        let batteryImpact: Double
        if batteryLevel > 80 {
            batteryImpact = 25.0
        } else if batteryLevel > 50 {
            batteryImpact = 20.0
        } else if batteryLevel > 20 {
            batteryImpact = 15.0
        } else {
            batteryImpact = 10.0
        }
        
        let storageImpact: Double
        if storagePercentage < 70 {
            storageImpact = 30.0
        } else if storagePercentage < 85 {
            storageImpact = 22.0
        } else if storagePercentage < 95 {
            storageImpact = 15.0
        } else {
            storageImpact = 8.0
        }
        
        var memoryInfo = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let memoryImpact: Double
        
        let result = withUnsafeMutablePointer(to: &memoryInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            let usedMemoryMB = Double(memoryInfo.resident_size) / 1_048_576
            let memoryPercentage = (usedMemoryMB / 2048.0) * 100
            
            if memoryPercentage < 60 {
                memoryImpact = 25.0
            } else if memoryPercentage < 75 {
                memoryImpact = 18.0
            } else if memoryPercentage < 90 {
                memoryImpact = 12.0
            } else {
                memoryImpact = 8.0
            }
        } else {
            memoryImpact = 20.0
        }
        
        let cpuImpact: Double = 20.0
        
        healthScore = batteryImpact + storageImpact + memoryImpact + cpuImpact
        
        if isCharging && batteryLevel < 100 {
            healthScore = min(100, healthScore + 5)
        }
        
        let finalScore = max(1, Int(healthScore))
        
        DispatchQueue.main.async {
            self.deviceHealth = finalScore
            
            if finalScore >= 90 {
                self.healthStatus = "Excellent"
            } else if finalScore >= 75 {
                self.healthStatus = "Good"
            } else if finalScore >= 60 {
                self.healthStatus = "Fair"
            } else {
                self.healthStatus = "Needs Attention"
            }
        }
    }
    
    private func calculateStorageUsage() {
        if let totalSpace = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemSize] as? Int64,
           let freeSpace = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemFreeSize] as? Int64 {
            
            let totalGB = Int(totalSpace / 1_000_000_000)
            let usedGB = Int((totalSpace - freeSpace) / 1_000_000_000)
            
            DispatchQueue.main.async {
                self.totalStorage = totalGB
                self.usedStorage = usedGB
                self.storagePercentage = Double(usedGB) / Double(totalGB) * 100
            }
        } else {
            DispatchQueue.main.async {
                self.totalStorage = 128
                self.usedStorage = 64
                self.storagePercentage = 50
            }
        }
    }
    
    private func updateBatteryStatus() {
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let level = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState
        
        DispatchQueue.main.async {
            if level >= 0 {
                self.batteryLevel = Int(level * 100)
            } else {
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
        }
    }
    
    func loadPerformanceModes() {
        DispatchQueue.main.async {
            self.isBatterySaverActive = UserDefaults.standard.bool(forKey: "batterySaverActive")
            self.isGamingModeActive = UserDefaults.standard.bool(forKey: "gamingModeActive")
        }
    }
    
    deinit {
        statusCheckTimer?.invalidate()
    }
}
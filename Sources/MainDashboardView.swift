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
    @State private var circleRotation: Double = 0
    @State private var numberScale: CGFloat = 1.0
    @State private var numberOpacity: Double = 1.0
    @State private var celebrationParticles: [CelebrationParticle] = []
    @State private var isRotating = false
    @State private var showRewardedAdBlock = false
    @State private var refreshCount = 0
    @State private var hasExtraRefresh = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.background
                    .ignoresSafeArea()
                
                FloatingParticlesView()
                
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
                
                ForEach(celebrationParticles) { particle in
                    CelebrationParticleView(particle: particle)
                }
                
                if showRewardedAdBlock {
                    RewardedAdBlockView(
                        message: "Watch a short ad to unlock one extra refresh and update your device status!",
                        onAdWatched: {
                            showRewardedAdBlock = false
                            hasExtraRefresh = true
                            performRefresh()
                        },
                        onCancel: {
                            showRewardedAdBlock = false
                            refreshCount = 0
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
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(themeManager.navigationText)
    }
    
    private func performCircleRotation() {
        guard !isRotating else { return }
        isRotating = true
        circleRotation = 0
        
        withAnimation(.easeInOut(duration: 1.0)) {
            circleRotation = 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            circleRotation = 0
            isRotating = false
        }
    }
    
    private func animateScoreChange(from oldScore: Int, to newScore: Int) {
        let duration = 1.0
        let steps = 20
        let stepDuration = duration / Double(steps)
        let increment = Double(newScore - oldScore) / Double(steps)
        
        for step in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(step)) {
                displayScore = oldScore + Int(increment * Double(step))
                
                if step == steps {
                    displayScore = newScore
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        numberOpacity = 1.0
                        numberScale = 1.1
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.9)) {
                            numberScale = 1.0
                        }
                    }
                    
                    if newScore >= 85 {
                        createCelebrationParticles()
                    }
                }
            }
        }
    }
    
    private func createCelebrationParticles() {
        celebrationParticles.removeAll()
        
        for _ in 0..<10 {
            let particle = CelebrationParticle(
                position: CGPoint(x: UIScreen.main.bounds.width / 2, y: 200),
                color: [themeManager.accentColor, themeManager.electricPink, themeManager.electricCyan, themeManager.neonGreen].randomElement()!,
                size: CGFloat.random(in: 4...8),
                velocity: CGPoint(
                    x: CGFloat.random(in: -120...120),
                    y: CGFloat.random(in: -150...(-40))
                )
            )
            celebrationParticles.append(particle)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            celebrationParticles.removeAll()
        }
    }
    
    private func performRefresh() {
        guard !isAnimatingScore else { return }
        
        isAnimatingScore = true
        
        performCircleRotation()
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
            showRefreshAnimation = true
        }
        
        let oldScore = displayScore
        viewModel.refreshPerformance()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let newScore = viewModel.deviceHealth
            animateScoreChange(from: oldScore, to: newScore)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                showRefreshAnimation = false
            }
            isAnimatingScore = false
            
            if hasExtraRefresh {
                hasExtraRefresh = false
                refreshCount = 0
            }
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
                
                Circle()
                    .trim(from: 0, to: CGFloat(displayScore) / 100)
                    .stroke(
                        themeManager.electricGradient,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90 + circleRotation))
                    .animation(.easeInOut(duration: 0.3), value: displayScore)
                    .shadow(
                        color: themeManager.enableGlowEffects ? themeManager.accentColor.opacity(0.5) : Color.clear,
                        radius: themeManager.enableGlowEffects ? 10 : 0,
                        x: 0,
                        y: 0
                    )
                
                VStack(spacing: 4) {
                    Text("\(displayScore)%")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(themeManager.electricGradient)
                        .scaleEffect(numberScale)
                        .opacity(numberOpacity)
                        .id("score-\(displayScore)")
                    
                    Text(viewModel.healthStatus)
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
                refreshCount += 1
                
                if refreshCount >= 2 && !hasExtraRefresh {
                    withAnimation {
                        showRewardedAdBlock = true
                    }
                } else {
                    performRefresh()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: showRefreshAnimation ? "checkmark.circle.fill" : "arrow.clockwise")
                        .font(.system(size: 18, weight: .bold))
                    
                    Text(showRefreshAnimation ? "REFRESHED!" : "REFRESH STATUS")
                        .font(.system(size: 16, weight: .bold))
                        .tracking(1.2)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    showRefreshAnimation ? 
                    themeManager.neonGreen : 
                    themeManager.buttonBackground
                )
                .cornerRadius(12)
                .scaleEffect(showRefreshAnimation ? 1.02 : 1.0)
                .shadow(
                    color: themeManager.enableGlowEffects ? (showRefreshAnimation ? themeManager.neonGreen.opacity(0.5) : themeManager.buttonBackground.opacity(0.3)) : Color.clear,
                    radius: themeManager.enableGlowEffects ? 12 : 0,
                    x: 0,
                    y: 0
                )
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
                        .rotationEffect(.degrees(isStorageCleanupExpanded ? 0 : 0))
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
                    .shadow(
                        color: themeManager.enableGlowEffects ? themeManager.accentColor.opacity(0.4) : Color.clear,
                        radius: themeManager.enableGlowEffects ? 8 : 0,
                        x: 0,
                        y: 0
                    )
                
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
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.cardBackground,
                                themeManager.cardBackground.opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(themeManager.isDarkMode ? 0.05 : 0.3),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                themeManager.accentColor.opacity(0.5),
                                themeManager.electricPink.opacity(0.3),
                                themeManager.electricCyan.opacity(0.5)
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
                    .shadow(
                        color: themeManager.enableGlowEffects && isActive ? themeManager.accentColor.opacity(0.5) : Color.clear,
                        radius: themeManager.enableGlowEffects ? 10 : 0,
                        x: 0,
                        y: 0
                    )
                
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
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(themeManager.isDarkMode ? 0.03 : 0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
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
        .shadow(
            color: themeManager.enableGlowEffects && isActive ? themeManager.glowColor.opacity(0.2) : Color.black.opacity(0.03),
            radius: themeManager.enableGlowEffects && isActive ? 12 : 6,
            x: 0,
            y: isActive ? 6 : 3
        )
    }
}

struct CelebrationParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    let color: Color
    let size: CGFloat
    let velocity: CGPoint
}

struct CelebrationParticleView: View {
    let particle: CelebrationParticle
    @State private var offset: CGPoint = .zero
    @State private var opacity: Double = 1.0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .fill(particle.color)
            .frame(width: particle.size, height: particle.size)
            .position(x: particle.position.x + offset.x, y: particle.position.y + offset.y)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeOut(duration: 1.2)) {
                    offset = CGPoint(
                        x: particle.velocity.x,
                        y: particle.velocity.y + 250
                    )
                    opacity = 0
                    scale = 0.3
                }
            }
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
        statusCheckTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
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
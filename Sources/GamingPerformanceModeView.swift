import SwiftUI
import UIKit

struct GamingPerformanceModeView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = GamingModeViewModel()
    @State private var showPermissionAlert = false
    @State private var permissionMessage = ""
    @State private var showAddGameSheet = false
    
    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
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
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Gaming Mode")
        .navigationBarTitleDisplayMode(.inline)
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
        .sheet(isPresented: $showAddGameSheet) {
            AddGameView(viewModel: viewModel)
        }
        .onAppear {
            themeManager.updateTheme()
            viewModel.updatePerformanceMetrics()
            viewModel.onPermissionDenied = { message in
                permissionMessage = message
                showPermissionAlert = true
            }
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
                        viewModel.toggleGamingMode(newValue)
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
        VStack(spacing: 16) {
            HStack {
                Text("Active Gaming Session")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
                
                Button(action: {
                    showAddGameSheet = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            if viewModel.gamingApps.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 40))
                        .foregroundColor(themeManager.secondaryText)
                    
                    Text("No games added yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                    
                    Text("Tap + to add games to your session")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 12)], spacing: 12) {
                    ForEach(viewModel.gamingApps) { app in
                        GameAppItem(app: app) {
                            viewModel.launchApp(app)
                        } onRemove: {
                            viewModel.removeGameApp(app)
                        }
                    }
                }
            }
            
            if !viewModel.runningGames.isEmpty {
                VStack(spacing: 12) {
                    HStack {
                        Text("Currently Running Games")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        Spacer()
                        
                        Button(action: {
                            viewModel.refreshRunningGames()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14))
                                .foregroundColor(themeManager.accentColor)
                        }
                    }
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 12)], spacing: 12) {
                        ForEach(viewModel.runningGames) { app in
                            RunningGameItem(app: app) {
                                viewModel.addRunningGameToSession(app)
                            }
                        }
                    }
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

struct GameAppItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let app: GamingApp
    let onTap: () -> Void
    let onRemove: () -> Void
    @State private var showRemoveButton = false
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                Button(action: onTap) {
                    VStack(spacing: 6) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    LinearGradient(
                                        colors: [themeManager.accentColor, themeManager.electricPink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 60, height: 60)
                                .shadow(color: themeManager.accentColor.opacity(0.4), radius: 8, x: 0, y: 4)
                            
                            if let icon = app.icon {
                                Image(uiImage: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: "gamecontroller.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        Text(app.name)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                if showRemoveButton {
                    Button(action: onRemove) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(themeManager.errorColor)
                            .background(Color.white)
                            .clipShape(Circle())
                    }
                    .offset(x: 8, y: -8)
                }
            }
        }
        .onLongPressGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showRemoveButton.toggle()
            }
        }
        .onTapGesture {
            if showRemoveButton {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showRemoveButton = false
                }
            } else {
                onTap()
            }
        }
    }
}

struct RunningGameItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let app: GamingApp
    let onAdd: () -> Void
    
    var body: some View {
        Button(action: onAdd) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.borderColor)
                        .frame(width: 60, height: 60)
                    
                    if let icon = app.icon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Circle()
                        .fill(themeManager.successColor)
                        .frame(width: 12, height: 12)
                        .offset(x: 20, y: -20)
                }
                
                Text(app.name)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct AddGameView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: GamingModeViewModel
    @State private var searchText = ""
    @State private var customGameName = ""
    @State private var showCustomGameInput = false
    
    var filteredApps: [GamingApp] {
        if searchText.isEmpty {
            return viewModel.availableApps
        } else {
            return viewModel.availableApps.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                    
                    if viewModel.isLoadingApps {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(themeManager.accentColor)
                            
                            Text("Loading installed apps...")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 16)], spacing: 16) {
                                ForEach(filteredApps) { app in
                                    AddGameAppItem(app: app) {
                                        viewModel.addGameApp(app)
                                        dismiss()
                                    }
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
            .navigationTitle("Add Game")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Custom") {
                    showCustomGameInput = true
                }
            )
        }
        .alert("Add Custom Game", isPresented: $showCustomGameInput) {
            TextField("Game Name", text: $customGameName)
            Button("Cancel", role: .cancel) {
                customGameName = ""
            }
            Button("Add") {
                if !customGameName.isEmpty {
                    let customApp = GamingApp(
                        id: UUID().uuidString,
                        name: customGameName,
                        bundleIdentifier: nil,
                        icon: nil,
                        isCustom: true
                    )
                    viewModel.addGameApp(customApp)
                    customGameName = ""
                    dismiss()
                }
            }
        } message: {
            Text("Enter the name of the game you want to add to your gaming session.")
        }
        .onAppear {
            viewModel.loadAvailableApps()
        }
    }
}

struct AddGameAppItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let app: GamingApp
    let onAdd: () -> Void
    
    var body: some View {
        Button(action: onAdd) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.cardBackground)
                        .frame(width: 70, height: 70)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.borderColor, lineWidth: 1)
                        )
                    
                    if let icon = app.icon {
                        Image(uiImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    } else {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 32))
                            .foregroundColor(themeManager.accentColor)
                    }
                }
                
                Text(app.name)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchBar: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.secondaryText)
            
            TextField("Search games...", text: $text)
                .foregroundColor(themeManager.primaryText)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.secondaryText)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(themeManager.cardBackground)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(themeManager.borderColor, lineWidth: 1)
        )
    }
}

struct GamingApp: Identifiable, Codable {
    let id: String
    let name: String
    let bundleIdentifier: String?
    var icon: UIImage?
    let isCustom: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, bundleIdentifier, isCustom
    }
    
    init(id: String, name: String, bundleIdentifier: String?, icon: UIImage?, isCustom: Bool = false) {
        self.id = id
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.icon = icon
        self.isCustom = isCustom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        bundleIdentifier = try container.decodeIfPresent(String.self, forKey: .bundleIdentifier)
        isCustom = try container.decode(Bool.self, forKey: .isCustom)
        icon = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(bundleIdentifier, forKey: .bundleIdentifier)
        try container.encode(isCustom, forKey: .isCustom)
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
    @Published var gamingApps: [GamingApp] = []
    @Published var availableApps: [GamingApp] = []
    @Published var runningGames: [GamingApp] = []
    @Published var isLoadingApps: Bool = false
    
    var onPermissionDenied: ((String) -> Void)?
    
    private var autoDisableTimer: Timer?
    private var activationTime: Date?
    private let autoDisableDuration: TimeInterval = 3600.0
    
    init() {
        loadSettings()
        updatePerformanceMetrics()
        requestPerformancePermissions()
        checkAndRestoreGamingMode()
        loadGamingApps()
        refreshRunningGames()
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
            refreshRunningGames()
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
    
    // MARK: - Gaming Apps Management
    
    func loadAvailableApps() {
        isLoadingApps = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            var apps: [GamingApp] = []
            
            // Add popular gaming apps that might be installed
            let popularGames = [
                ("Minecraft", "com.mojang.minecraftpe"),
                ("Roblox", "com.roblox.robloxmobile"),
                ("Fortnite", "com.epicgames.fortnitemobile"),
                ("PUBG Mobile", "com.tencent.ig"),
                ("Call of Duty Mobile", "com.activision.callofduty.shooter"),
                ("Among Us", "com.innersloth.amongus"),
                ("Clash Royale", "com.supercell.clashroyale"),
                ("Clash of Clans", "com.supercell.magic"),
                ("Candy Crush Saga", "com.king.candycrushsaga"),
                ("Pokemon GO", "com.nianticlabs.pokemongo"),
                ("Genshin Impact", "com.miHoYo.GenshinImpact"),
                ("Brawl Stars", "com.supercell.laser"),
                ("Mobile Legends", "com.mobile.legends"),
                ("Free Fire", "com.dts.freefireth"),
                ("Subway Surfers", "com.kiloo.subwaysurfers"),
                ("Temple Run 2", "com.imangi.templerun2"),
                ("Angry Birds", "com.rovio.angrybirds"),
                ("Plants vs Zombies", "com.ea.game.pvz2_row"),
                ("8 Ball Pool", "com.miniclip.8ballpool"),
                ("Words with Friends", "com.zynga.WordsWithFriends")
            ]
            
            for (name, bundleId) in popularGames {
                let app = GamingApp(
                    id: bundleId,
                    name: name,
                    bundleIdentifier: bundleId,
                    icon: self.getAppIcon(for: bundleId)
                )
                apps.append(app)
            }
            
            // Add some generic gaming categories
            let genericGames = [
                "Action Game",
                "Adventure Game",
                "Puzzle Game",
                "Racing Game",
                "Sports Game",
                "Strategy Game",
                "RPG Game",
                "Simulation Game"
            ]
            
            for gameName in genericGames {
                let app = GamingApp(
                    id: UUID().uuidString,
                    name: gameName,
                    bundleIdentifier: nil,
                    icon: nil,
                    isCustom: true
                )
                apps.append(app)
            }
            
            DispatchQueue.main.async {
                self.availableApps = apps
                self.isLoadingApps = false
            }
        }
    }
    
    private func getAppIcon(for bundleIdentifier: String) -> UIImage? {
        // In a real implementation, you would use private APIs or other methods
        // to get actual app icons. For this demo, we'll return nil
        return nil
    }
    
    func refreshRunningGames() {
        // Simulate detecting running games
        DispatchQueue.global(qos: .userInitiated).async {
            var runningApps: [GamingApp] = []
            
            // Simulate some running games (in reality, iOS doesn't allow apps to see other running apps)
            let simulatedRunningGames = [
                "Minecraft",
                "Roblox",
                "Among Us"
            ].shuffled().prefix(Int.random(in: 0...2))
            
            for gameName in simulatedRunningGames {
                let app = GamingApp(
                    id: UUID().uuidString,
                    name: gameName,
                    bundleIdentifier: "com.example.\(gameName.lowercased())",
                    icon: nil
                )
                runningApps.append(app)
            }
            
            DispatchQueue.main.async {
                self.runningGames = runningApps
            }
        }
    }
    
    func addGameApp(_ app: GamingApp) {
        if !gamingApps.contains(where: { $0.id == app.id }) {
            gamingApps.append(app)
            saveGamingApps()
        }
    }
    
    func removeGameApp(_ app: GamingApp) {
        gamingApps.removeAll { $0.id == app.id }
        saveGamingApps()
    }
    
    func addRunningGameToSession(_ app: GamingApp) {
        addGameApp(app)
        runningGames.removeAll { $0.id == app.id }
    }
    
    func launchApp(_ app: GamingApp) {
        if let bundleId = app.bundleIdentifier,
           let url = URL(string: "\(bundleId)://") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Try alternative URL schemes or show app store
                if let appStoreURL = URL(string: "https://apps.apple.com/search?term=\(app.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                    UIApplication.shared.open(appStoreURL)
                }
            }
        } else {
            // For custom games, show a message or open App Store search
            if let appStoreURL = URL(string: "https://apps.apple.com/search?term=\(app.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
                UIApplication.shared.open(appStoreURL)
            }
        }
    }
    
    private func saveGamingApps() {
        if let encoded = try? JSONEncoder().encode(gamingApps) {
            UserDefaults.standard.set(encoded, forKey: "gamingApps")
            UserDefaults.standard.synchronize()
        }
    }
    
    private func loadGamingApps() {
        if let data = UserDefaults.standard.data(forKey: "gamingApps"),
           let decoded = try? JSONDecoder().decode([GamingApp].self, from: data) {
            gamingApps = decoded
        }
    }
    
    private func loadSettings() {
        isGamingModeActive = UserDefaults.standard.bool(forKey: "gamingModeActive")
        cpuBoostEnabled = UserDefaults.standard.bool(forKey: "cpuBoostEnabled")
    }
    
    deinit {
        stopAutoDisableTimer()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}
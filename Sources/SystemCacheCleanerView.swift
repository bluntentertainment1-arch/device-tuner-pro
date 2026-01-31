import SwiftUI

struct SystemCacheCleanerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var adManager: AdManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = SystemCacheViewModel()
    @State private var showClearConfirmation = false
    
    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
            if viewModel.isScanning {
                scanningView
            } else {
                cacheContentView
            }
            
            if viewModel.isClearing {
                clearingOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Spacer()
                    Text("System Cache")
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
        .alert("Clear Cache", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                viewModel.clearCache()
            }
        } message: {
            Text("Are you sure you want to clear \(viewModel.totalCacheSize) of cache data? This action cannot be undone.")
        }
        .alert("Success", isPresented: $viewModel.showSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.successMessage)
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            themeManager.updateTheme()
            viewModel.scanCache()
        }
    }
    
    private var scanningView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(themeManager.accentColor)
            
            Text("Scanning Cache...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            
            Text("Analyzing temporary files")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
        }
    }
    
    private var cacheContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                cacheOverviewCard
                cacheBreakdownCard
                tipsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .overlay(alignment: .bottom) {
            clearButtonOverlay
        }
    }
    
    private var cacheOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Cache Overview")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            ZStack {
                Circle()
                    .stroke(themeManager.borderColor, lineWidth: 12)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: 0.75)
                    .stroke(
                        LinearGradient(
                            colors: [themeManager.neonPurple, themeManager.electricPink],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 4) {
                    Text(viewModel.totalCacheSize)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Cache Data")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
            }
            .padding(.vertical, 20)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(viewModel.cacheItems.count)")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                    
                    Text("Items")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Divider()
                    .frame(height: 40)
                    .background(themeManager.borderColor)
                
                VStack(spacing: 4) {
                    Text(viewModel.lastClearedDate)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                    
                    Text("Last Cleared")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
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
                        colors: [themeManager.neonPurple, themeManager.electricPink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: themeManager.neonPurple.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    private var cacheBreakdownCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Cache Breakdown")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.cacheItems) { item in
                    cacheItemRow(item: item)
                }
            }
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var tipsCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Cache Cleaning Tips")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                tipRow(icon: "clock", text: "Clear cache regularly to maintain optimal performance")
                tipRow(icon: "arrow.clockwise", text: "Apps will rebuild cache as needed after clearing")
                tipRow(icon: "checkmark.shield", text: "Safe to clear - no personal data will be lost")
                tipRow(icon: "speedometer", text: "May improve app launch times and responsiveness")
            }
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeManager.borderColor, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var clearButtonOverlay: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button(action: {
                    viewModel.scanCache()
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Rescan")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(themeManager.cardBackground)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.borderColor, lineWidth: 1)
                    )
                }
                
                Button(action: {
                    if viewModel.totalCacheSizeBytes > 0 {
                        showClearConfirmation = true
                    }
                }) {
                    HStack {
                        Image(systemName: "trash")
                        Text("Clear Cache")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(viewModel.totalCacheSizeBytes > 0 ? themeManager.buttonText : themeManager.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        viewModel.totalCacheSizeBytes > 0 ? 
                        LinearGradient(
                            colors: [themeManager.neonPurple, themeManager.electricPink],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) : 
                        LinearGradient(
                            colors: [themeManager.borderColor],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                    .shadow(
                        color: viewModel.totalCacheSizeBytes > 0 ? themeManager.neonPurple.opacity(0.5) : Color.clear,
                        radius: 8,
                        x: 0,
                        y: 0
                    )
                }
                .disabled(viewModel.totalCacheSizeBytes == 0)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(themeManager.cardBackground)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
        }
    }
    
    private var clearingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.white)
                
                Text("Clearing Cache...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white)
            }
            .padding(40)
            .background(themeManager.cardBackground)
            .cornerRadius(16)
        }
    }
    
    private func cacheItemRow(item: CacheItem) -> some View {
        HStack(spacing: 12) {
            Image(systemName: item.icon)
                .font(.system(size: 20))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 40, height: 40)
                .background(themeManager.accentColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                
                Text(item.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
            
            Text(item.sizeString)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.accentColor)
        }
        .padding(12)
        .background(themeManager.background)
        .cornerRadius(8)
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

struct CacheItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let size: Int64
    let icon: String
    
    var sizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

class SystemCacheViewModel: ObservableObject {
    @Published var cacheItems: [CacheItem] = []
    @Published var isScanning = false
    @Published var isClearing = false
    @Published var showSuccess = false
    @Published var showError = false
    @Published var successMessage = ""
    @Published var errorMessage = ""
    @Published var lastClearedDate = "Never"
    
    var totalCacheSizeBytes: Int64 {
        cacheItems.reduce(0) { $0 + $1.size }
    }
    
    var totalCacheSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: totalCacheSizeBytes)
    }
    
    init() {
        loadLastClearedDate()
    }
    
    func scanCache() {
        DispatchQueue.main.async {
            self.isScanning = true
            self.cacheItems = []
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var items: [CacheItem] = []
            
            if let cacheSize = self.getCacheDirectorySize() {
                items.append(CacheItem(
                    name: "App Cache",
                    description: "Temporary app data and files",
                    size: cacheSize,
                    icon: "folder"
                ))
            }
            
            if let tmpSize = self.getTempDirectorySize() {
                items.append(CacheItem(
                    name: "Temporary Files",
                    description: "System temporary files",
                    size: tmpSize,
                    icon: "doc.text"
                ))
            }
            
            if let urlCacheSize = self.getURLCacheSize() {
                items.append(CacheItem(
                    name: "Web Cache",
                    description: "Cached web content and images",
                    size: urlCacheSize,
                    icon: "globe"
                ))
            }
            
            DispatchQueue.main.async {
                self.cacheItems = items
                self.isScanning = false
            }
        }
    }
    
    func clearCache() {
        DispatchQueue.main.async {
            self.isClearing = true
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var clearedSize: Int64 = 0
            
            clearedSize += self.clearCacheDirectory()
            clearedSize += self.clearTempDirectory()
            clearedSize += self.clearURLCache()
            
            DispatchQueue.main.async {
                self.isClearing = false
                
                let formatter = ByteCountFormatter()
                formatter.allowedUnits = [.useMB]
                formatter.countStyle = .file
                let sizeString = formatter.string(fromByteCount: clearedSize)
                
                self.successMessage = "Successfully cleared \(sizeString) of cache data"
                self.showSuccess = true
                
                self.saveLastClearedDate()
                self.scanCache()
            }
        }
    }
    
    private func getCacheDirectorySize() -> Int64? {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return nil
        }
        return directorySize(at: cacheURL)
    }
    
    private func getTempDirectorySize() -> Int64? {
        let tmpURL = FileManager.default.temporaryDirectory
        return directorySize(at: tmpURL)
    }
    
    private func getURLCacheSize() -> Int64? {
        let cache = URLCache.shared
        return Int64(cache.currentDiskUsage)
    }
    
    private func clearCacheDirectory() -> Int64 {
        guard let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            return 0
        }
        
        let size = directorySize(at: cacheURL) ?? 0
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: cacheURL, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            return 0
        }
        
        return size
    }
    
    private func clearTempDirectory() -> Int64 {
        let tmpURL = FileManager.default.temporaryDirectory
        let size = directorySize(at: tmpURL) ?? 0
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: tmpURL, includingPropertiesForKeys: nil)
            for fileURL in contents {
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            return 0
        }
        
        return size
    }
    
    private func clearURLCache() -> Int64 {
        let cache = URLCache.shared
        let size = Int64(cache.currentDiskUsage)
        cache.removeAllCachedResponses()
        return size
    }
    
    private func directorySize(at url: URL) -> Int64? {
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return nil
        }
        
        var totalSize: Int64 = 0
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                if let fileSize = resourceValues.fileSize {
                    totalSize += Int64(fileSize)
                }
            } catch {
                continue
            }
        }
        
        return totalSize
    }
    
    private func saveLastClearedDate() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateString = formatter.string(from: Date())
        UserDefaults.standard.set(dateString, forKey: "lastCacheClearedDate")
        lastClearedDate = dateString
    }
    
    private func loadLastClearedDate() {
        if let dateString = UserDefaults.standard.string(forKey: "lastCacheClearedDate") {
            lastClearedDate = dateString
        }
    }
}
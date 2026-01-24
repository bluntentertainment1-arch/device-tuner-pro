import SwiftUI

struct StorageDetailView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = StorageDetailViewModel()
    
    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                loadingView
            } else {
                storageContentView
            }
        }
        .navigationTitle("Storage Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            themeManager.updateTheme()
            viewModel.loadStorageData()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(themeManager.accentColor)
            
            Text("Analyzing Storage...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
        }
    }
    
    private var storageContentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                storageOverviewCard
                storageBreakdownCard
                disclaimerCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
    }
    
    private var storageOverviewCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Storage Overview")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            ZStack {
                Circle()
                    .stroke(themeManager.borderColor, lineWidth: 12)
                    .frame(width: 150, height: 150)
                
                Circle()
                    .trim(from: 0, to: CGFloat(viewModel.storagePercentage) / 100)
                    .stroke(
                        LinearGradient(
                            colors: viewModel.storagePercentage > 90 ? [themeManager.errorColor, themeManager.warningColor] : viewModel.storagePercentage > 70 ? [themeManager.warningColor, themeManager.accentColor] : [themeManager.accentColor, themeManager.electricCyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: viewModel.storagePercentage)
                
                VStack(spacing: 4) {
                    Text("\(Int(viewModel.storagePercentage))%")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Used")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
            }
            .padding(.vertical, 20)
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(viewModel.usedStorage) GB")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                    
                    Text("Used")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Divider()
                    .frame(height: 40)
                    .background(themeManager.borderColor)
                
                VStack(spacing: 4) {
                    Text("\(viewModel.freeStorage) GB")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.successColor)
                    
                    Text("Available")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Divider()
                    .frame(height: 40)
                    .background(themeManager.borderColor)
                
                VStack(spacing: 4) {
                    Text("\(viewModel.totalStorage) GB")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("Total")
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
                        colors: [themeManager.accentColor, themeManager.electricCyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 12, x: 0, y: 6)
    }
    
    private var storageBreakdownCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Storage Breakdown")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(viewModel.storageCategories) { category in
                    storageCategoryRow(category: category)
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
    
    private var disclaimerCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.accentColor)
                
                Text("Estimated System Data")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
            }
            
            Text("Storage information is based on system-reported data and may vary from actual device storage. Some system files and cached data may not be included in the breakdown.")
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
    
    private func storageCategoryRow(category: StorageCategory) -> some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(category.color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(category.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(category.description)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(category.sizeString)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text("\(Int(category.percentage))%")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(themeManager.borderColor)
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(category.color)
                        .frame(width: geometry.size.width * CGFloat(category.percentage) / 100, height: 6)
                        .animation(.easeInOut(duration: 1.0), value: category.percentage)
                }
            }
            .frame(height: 6)
        }
        .padding(12)
        .background(themeManager.background)
        .cornerRadius(8)
    }
}

struct StorageCategory: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let size: Int64
    let percentage: Double
    let icon: String
    let color: Color
    
    var sizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useGB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

class StorageDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var totalStorage: Int = 0
    @Published var usedStorage: Int = 0
    @Published var freeStorage: Int = 0
    @Published var storagePercentage: Double = 0
    @Published var storageCategories: [StorageCategory] = []
    
    func loadStorageData() {
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            self.calculateStorageUsage()
            self.calculateStorageBreakdown()
            
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func calculateStorageUsage() {
        do {
            let fileURL = URL(fileURLWithPath: NSHomeDirectory())
            let values = try fileURL.resourceValues(forKeys: [.volumeTotalCapacityKey, .volumeAvailableCapacityKey])
            
            if let totalSpace = values.volumeTotalCapacity,
               let freeSpace = values.volumeAvailableCapacity {
                
                let totalGB = Int(Int64(totalSpace) / 1_000_000_000)
                let freeGB = Int(Int64(freeSpace) / 1_000_000_000)
                let usedGB = totalGB - freeGB
                
                DispatchQueue.main.async {
                    self.totalStorage = totalGB
                    self.freeStorage = freeGB
                    self.usedStorage = usedGB
                    self.storagePercentage = totalGB > 0 ? Double(usedGB) / Double(totalGB) * 100 : 0
                }
            } else {
                self.setDefaultStorageValues()
            }
        } catch {
            self.setDefaultStorageValues()
        }
    }
    
    private func setDefaultStorageValues() {
        DispatchQueue.main.async {
            self.totalStorage = 128
            self.freeStorage = 64
            self.usedStorage = 64
            self.storagePercentage = 50
        }
    }
    
    private func calculateStorageBreakdown() {
        var categories: [StorageCategory] = []
        
        let documentsSize = getDirectorySize(for: .documentDirectory)
        let cacheSize = getDirectorySize(for: .cachesDirectory)
        let tempSize = getTempDirectorySize()
        let appSize = getAppSize()
        
        let totalUsedBytes = Int64(usedStorage) * 1_000_000_000
        let accountedBytes = documentsSize + cacheSize + tempSize + appSize
        let systemBytes = max(0, totalUsedBytes - accountedBytes)
        
        if appSize > 0 {
            categories.append(StorageCategory(
                name: "App Data",
                description: "Application files and resources",
                size: appSize,
                percentage: totalUsedBytes > 0 ? Double(appSize) / Double(totalUsedBytes) * 100 : 0,
                icon: "app.fill",
                color: ThemeManager.shared.accentColor
            ))
        }
        
        if documentsSize > 0 {
            categories.append(StorageCategory(
                name: "Documents",
                description: "User documents and files",
                size: documentsSize,
                percentage: totalUsedBytes > 0 ? Double(documentsSize) / Double(totalUsedBytes) * 100 : 0,
                icon: "doc.fill",
                color: ThemeManager.shared.electricCyan
            ))
        }
        
        if cacheSize > 0 {
            categories.append(StorageCategory(
                name: "Cache",
                description: "Temporary cached data",
                size: cacheSize,
                percentage: totalUsedBytes > 0 ? Double(cacheSize) / Double(totalUsedBytes) * 100 : 0,
                icon: "folder.fill",
                color: ThemeManager.shared.neonPurple
            ))
        }
        
        if tempSize > 0 {
            categories.append(StorageCategory(
                name: "Temporary Files",
                description: "System temporary files",
                size: tempSize,
                percentage: totalUsedBytes > 0 ? Double(tempSize) / Double(totalUsedBytes) * 100 : 0,
                icon: "clock.fill",
                color: ThemeManager.shared.warningColor
            ))
        }
        
        if systemBytes > 0 {
            categories.append(StorageCategory(
                name: "System & Other",
                description: "iOS system files and other data",
                size: systemBytes,
                percentage: totalUsedBytes > 0 ? Double(systemBytes) / Double(totalUsedBytes) * 100 : 0,
                icon: "gearshape.fill",
                color: ThemeManager.shared.secondaryText
            ))
        }
        
        DispatchQueue.main.async {
            self.storageCategories = categories.sorted { $0.size > $1.size }
        }
    }
    
    private func getDirectorySize(for directory: FileManager.SearchPathDirectory) -> Int64 {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return 0
        }
        return directorySize(at: url)
    }
    
    private func getTempDirectorySize() -> Int64 {
        let tmpURL = FileManager.default.temporaryDirectory
        return directorySize(at: tmpURL)
    }
    
    private func getAppSize() -> Int64 {
        guard let bundlePath = Bundle.main.bundlePath as NSString? else {
            return 0
        }
        return directorySize(at: URL(fileURLWithPath: bundlePath as String))
    }
    
    private func directorySize(at url: URL) -> Int64 {
        var totalSize: Int64 = 0
        
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isDirectoryKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey, .isDirectoryKey])
                
                if let isDirectory = resourceValues.isDirectory, !isDirectory {
                    if let fileSize = resourceValues.fileSize {
                        totalSize += Int64(fileSize)
                    }
                }
            } catch {
                continue
            }
        }
        
        return totalSize
    }
}
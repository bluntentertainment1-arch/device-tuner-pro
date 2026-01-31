import SwiftUI
import Photos
import CryptoKit

struct DuplicatePhotoScannerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var adManager: AdManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = DuplicatePhotoViewModel()
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
            if viewModel.isScanning {
                scanningView
            } else if viewModel.duplicateGroups.isEmpty {
                emptyStateView
            } else {
                duplicateGroupsView
            }
            
            if viewModel.isDeleting {
                deletingOverlay
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Spacer()
                    Text("Duplicate Photos")
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
        .alert("Photo Library Access Required", isPresented: $showPermissionAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Open Settings") {
                openPhotoSettings()
            }
        } message: {
            Text(permissionAlertMessage)
        }
        .alert("Delete Photos", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteSelectedPhotos()
            }
        } message: {
            Text("Are you sure you want to delete \(viewModel.selectedPhotos.count) photo(s)? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            themeManager.updateTheme()
            viewModel.checkPhotoLibraryPermission { granted, message in
                if !granted {
                    permissionAlertMessage = message
                    showPermissionAlert = true
                }
            }
        }
    }
    
    private func openPhotoSettings() {
        if let url = URL(string: "App-Prefs:Privacy&path=PHOTOS") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        } else if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    private var scanningView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(themeManager.accentColor)
            
            Text("Scanning for Duplicates...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            
            Text("Analyzed \(viewModel.scannedCount) photos")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
            
            if viewModel.duplicateGroups.count > 0 {
                Text("Found \(viewModel.duplicateGroups.count) duplicate groups")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.accentColor)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.stack")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryText)
            
            Text(viewModel.hasScanned ? "No Duplicates Found" : "Scan for Duplicates")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            
            Text(viewModel.hasScanned ? "Your photo library is clean!" : "Tap the button below to scan your photo library for duplicate photos")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                viewModel.scanForDuplicates { granted, message in
                    if !granted {
                        permissionAlertMessage = message
                        showPermissionAlert = true
                    }
                }
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Scan for Duplicates")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.buttonText)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(themeManager.buttonBackground)
                .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.top, 16)
        }
    }
    
    private var duplicateGroupsView: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("\(viewModel.duplicateGroups.count) Duplicate Groups Found")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Spacer()
                        
                        Text("\(viewModel.totalDuplicateSize) MB")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.accentColor)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    ForEach(viewModel.duplicateGroups) { group in
                        DuplicateGroupCard(group: group, viewModel: viewModel)
                    }
                }
                .padding(.bottom, 100)
            }
            
            VStack(spacing: 12) {
                if !viewModel.selectedPhotos.isEmpty {
                    HStack {
                        Text("\(viewModel.selectedPhotos.count) photo(s) selected")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.clearSelection()
                        }) {
                            Text("Clear")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.accentColor)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.scanForDuplicates { granted, message in
                            if !granted {
                                permissionAlertMessage = message
                                showPermissionAlert = true
                            }
                        }
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
                        if !viewModel.selectedPhotos.isEmpty {
                            showDeleteConfirmation = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.selectedPhotos.isEmpty ? themeManager.secondaryText : themeManager.buttonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.selectedPhotos.isEmpty ? themeManager.borderColor : themeManager.errorColor)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedPhotos.isEmpty)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .background(themeManager.cardBackground)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: -4)
        }
    }
    
    private var deletingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Color.white)
                
                Text("Deleting Photos...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white)
            }
            .padding(40)
            .background(themeManager.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct DuplicateGroupCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let group: DuplicateGroup
    @ObservedObject var viewModel: DuplicatePhotoViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    if let firstPhoto = group.photos.first, let image = firstPhoto.thumbnail {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(group.photos.count) Duplicates")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text("\(group.totalSize) MB")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            if isExpanded {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(group.photos) { photo in
                        DuplicatePhotoItem(photo: photo, isSelected: viewModel.selectedPhotos.contains(photo.id)) {
                            viewModel.togglePhotoSelection(photo.id)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.borderColor, lineWidth: 1)
        )
        .padding(.horizontal, 20)
    }
}

struct DuplicatePhotoItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let photo: PhotoItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let image = photo.thumbnail {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(themeManager.borderColor)
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
                    .overlay(
                        ProgressView()
                            .tint(themeManager.accentColor)
                    )
            }
            
            if isSelected {
                ZStack {
                    Circle()
                        .fill(themeManager.accentColor)
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.white)
                }
                .padding(6)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 3)
        )
        .onTapGesture {
            onTap()
        }
    }
}

struct DuplicateGroup: Identifiable {
    let id = UUID()
    let hash: String
    var photos: [PhotoItem]
    var totalSize: String
}

class DuplicatePhotoViewModel: ObservableObject {
    @Published var duplicateGroups: [DuplicateGroup] = []
    @Published var selectedPhotos: Set<String> = []
    @Published var isScanning = false
    @Published var isDeleting = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var scannedCount = 0
    @Published var hasScanned = false
    
    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 200, height: 200)
    private let batchSize = 20
    
    var totalDuplicateSize: String {
        let total = duplicateGroups.reduce(0.0) { sum, group in
            sum + (Double(group.totalSize.replacingOccurrences(of: " MB", with: "")) ?? 0.0)
        }
        return String(format: "%.1f", total)
    }
    
    func checkPhotoLibraryPermission(completion: @escaping (Bool, String) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized:
            completion(true, "")
        case .limited:
            completion(true, "Limited access granted. Some photos may not be visible.")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized:
                        completion(true, "")
                    case .limited:
                        completion(true, "Limited access granted. Some photos may not be visible.")
                    case .denied:
                        completion(false, "Photo library access was denied. Please go to Settings > Privacy & Security > Photos and enable access for Device Tuner PRO 26 to scan for duplicate photos.")
                    case .restricted:
                        completion(false, "Photo library access is restricted. This may be due to parental controls or device management policies.")
                    default:
                        completion(false, "Unable to access photo library. Please check your privacy settings.")
                    }
                }
            }
        case .denied:
            completion(false, "Photo library access was denied. Please go to Settings > Privacy & Security > Photos and enable access for Device Tuner PRO 26 to scan for duplicate photos.")
        case .restricted:
            completion(false, "Photo library access is restricted. This may be due to parental controls or device management policies.")
        @unknown default:
            completion(false, "Unable to access photo library. Please check your privacy settings.")
        }
    }
    
    func scanForDuplicates(completion: @escaping (Bool, String) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch status {
        case .authorized, .limited:
            performScan()
            completion(true, "")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    switch newStatus {
                    case .authorized, .limited:
                        self.performScan()
                        completion(true, "")
                    case .denied:
                        completion(false, "Photo library access was denied. Please go to Settings > Privacy & Security > Photos and enable access for Device Tuner PRO 26.")
                    case .restricted:
                        completion(false, "Photo library access is restricted. This may be due to parental controls or device management policies.")
                    default:
                        completion(false, "Unable to access photo library. Please check your privacy settings.")
                    }
                }
            }
        case .denied:
            completion(false, "Photo library access was denied. Please go to Settings > Privacy & Security > Photos and enable access for Device Tuner PRO 26.")
        case .restricted:
            completion(false, "Photo library access is restricted. This may be due to parental controls or device management policies.")
        @unknown default:
            completion(false, "Unable to access photo library. Please check your privacy settings.")
        }
    }
    
    private func performScan() {
        DispatchQueue.main.async {
            self.isScanning = true
            self.duplicateGroups = []
            self.selectedPhotos = []
            self.scannedCount = 0
            self.hasScanned = false
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            var photosByHash: [String: [PhotoItem]] = [:]
            let semaphore = DispatchSemaphore(value: self.batchSize)
            let group = DispatchGroup()
            
            assets.enumerateObjects { asset, _, _ in
                group.enter()
                semaphore.wait()
                
                DispatchQueue.main.async {
                    self.scannedCount += 1
                }
                
                let options = PHImageRequestOptions()
                options.isSynchronous = false
                options.deliveryMode = .fastFormat
                options.isNetworkAccessAllowed = true
                options.resizeMode = .fast
                
                self.imageManager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, _ in
                    defer {
                        group.leave()
                        semaphore.signal()
                    }
                    
                    guard let imageData = data else { return }
                    
                    let hash = self.hashImageData(imageData)
                    let photoItem = PhotoItem(id: asset.localIdentifier, asset: asset, thumbnail: nil)
                    
                    DispatchQueue.main.async {
                        if photosByHash[hash] != nil {
                            photosByHash[hash]?.append(photoItem)
                        } else {
                            photosByHash[hash] = [photoItem]
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                var duplicates: [DuplicateGroup] = []
                
                for (hash, photos) in photosByHash {
                    if photos.count > 1 {
                        let totalBytes = photos.reduce(0) { sum, photo in
                            let resources = PHAssetResource.assetResources(for: photo.asset)
                            let size = resources.first?.value(forKey: "fileSize") as? Int ?? 0
                            return sum + size
                        }
                        let totalMB = String(format: "%.1f", Double(totalBytes) / 1_000_000)
                        
                        let group = DuplicateGroup(hash: hash, photos: photos, totalSize: totalMB)
                        duplicates.append(group)
                    }
                }
                
                self.duplicateGroups = duplicates.sorted { $0.photos.count > $1.photos.count }
                self.isScanning = false
                self.hasScanned = true
                self.loadThumbnailsInBatches()
            }
        }
    }
    
    private func hashImageData(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func loadThumbnailsInBatches() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        
        for (groupIndex, group) in duplicateGroups.enumerated() {
            for (photoIndex, photo) in group.photos.enumerated() {
                imageManager.requestImage(
                    for: photo.asset,
                    targetSize: thumbnailSize,
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    DispatchQueue.main.async {
                        if groupIndex < self.duplicateGroups.count && photoIndex < self.duplicateGroups[groupIndex].photos.count {
                            self.duplicateGroups[groupIndex].photos[photoIndex].thumbnail = image
                        }
                    }
                }
            }
        }
    }
    
    func togglePhotoSelection(_ id: String) {
        if selectedPhotos.contains(id) {
            selectedPhotos.remove(id)
        } else {
            selectedPhotos.insert(id)
        }
    }
    
    func clearSelection() {
        selectedPhotos.removeAll()
    }
    
    func deleteSelectedPhotos() {
        guard !selectedPhotos.isEmpty else { return }
        
        var assetsToDelete: [PHAsset] = []
        
        for group in duplicateGroups {
            for photo in group.photos {
                if selectedPhotos.contains(photo.id) {
                    assetsToDelete.append(photo.asset)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.isDeleting = true
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
        }) { success, error in
            DispatchQueue.main.async {
                self.isDeleting = false
                
                if success {
                    for (groupIndex, group) in self.duplicateGroups.enumerated().reversed() {
                        self.duplicateGroups[groupIndex].photos.removeAll { self.selectedPhotos.contains($0.id) }
                        
                        if self.duplicateGroups[groupIndex].photos.count <= 1 {
                            self.duplicateGroups.remove(at: groupIndex)
                        }
                    }
                    
                    self.selectedPhotos.removeAll()
                } else {
                    self.errorMessage = error?.localizedDescription ?? "Failed to delete photos. Please ensure you have granted full photo library access in Settings > Privacy & Security > Photos."
                    self.showError = true
                }
            }
        }
    }
}
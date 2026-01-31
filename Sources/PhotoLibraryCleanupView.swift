import SwiftUI
import Photos
import PhotosUI

struct PhotoLibraryCleanupView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var adManager: AdManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PhotoCleanupViewModel()
    @State private var showPermissionAlert = false
    @State private var permissionAlertMessage = ""
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                if viewModel.isScanning {
                    scanningView
                } else if viewModel.photos.isEmpty {
                    emptyStateView
                } else {
                    photoGridView
                }
                
                if !viewModel.isScanning && !viewModel.photos.isEmpty {
                    BannerAdView(adUnitID: adManager.bannerAdUnitID)
                        .frame(height: adManager.bannerViewHeight)
                        .background(themeManager.cardBackground)
                }
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
                    Text("Photo Cleanup")
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                adManager.showInterstitialAd()
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
            
            Text("Scanning Photo Library...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            
            Text("Found \(viewModel.photos.count) photos")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryText)
            
            Text("No Photos Found")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            
            Text("Tap the button below to scan your photo library")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                viewModel.scanPhotoLibrary { granted, message in
                    if !granted {
                        permissionAlertMessage = message
                        showPermissionAlert = true
                    }
                }
            }) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Scan Photo Library")
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
    
    private var photoGridView: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 8)], spacing: 8) {
                    ForEach(viewModel.photos) { photo in
                        PhotoGridItem(photo: photo, isSelected: viewModel.selectedPhotos.contains(photo.id)) {
                            viewModel.togglePhotoSelection(photo.id)
                        }
                    }
                }
                .padding(16)
                .padding(.bottom, max(100, adManager.bannerViewHeight + 100))
            }
            .scrollIndicators(.hidden)
            
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
                        viewModel.scanPhotoLibrary { granted, message in
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

struct PhotoGridItem: View {
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

struct PhotoItem: Identifiable {
    let id: String
    let asset: PHAsset
    var thumbnail: UIImage?
}

class PhotoCleanupViewModel: ObservableObject {
    @Published var photos: [PhotoItem] = []
    @Published var selectedPhotos: Set<String> = []
    @Published var isScanning = false
    @Published var isDeleting = false
    @Published var showError = false
    @Published var errorMessage = ""
    
    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 150, height: 150)
    private let batchSize = 30
    
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
                        completion(false, "Photo library access was denied. Please go to Settings > Privacy & Security > Photos and enable access for Device Tuner PRO 26 to scan and manage your photos.")
                    case .restricted:
                        completion(false, "Photo library access is restricted. This may be due to parental controls or device management policies.")
                    default:
                        completion(false, "Unable to access photo library. Please check your privacy settings.")
                    }
                }
            }
        case .denied:
            completion(false, "Photo library access was denied. Please go to Settings > Privacy & Security > Photos and enable access for Device Tuner PRO 26 to scan and manage your photos.")
        case .restricted:
            completion(false, "Photo library access is restricted. This may be due to parental controls or device management policies.")
        @unknown default:
            completion(false, "Unable to access photo library. Please check your privacy settings.")
        }
    }
    
    func scanPhotoLibrary(completion: @escaping (Bool, String) -> Void) {
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
            self.photos = []
            self.selectedPhotos = []
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 100
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var tempPhotos: [PhotoItem] = []
        
        assets.enumerateObjects { asset, _, _ in
            let photoItem = PhotoItem(id: asset.localIdentifier, asset: asset, thumbnail: nil)
            tempPhotos.append(photoItem)
        }
        
        DispatchQueue.main.async {
            self.photos = tempPhotos
            self.isScanning = false
            self.loadThumbnailsInBatches()
        }
    }
    
    private func loadThumbnailsInBatches() {
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        options.resizeMode = .fast
        
        let totalPhotos = photos.count
        var currentIndex = 0
        
        func loadNextBatch() {
            guard currentIndex < totalPhotos else { return }
            
            let endIndex = min(currentIndex + batchSize, totalPhotos)
            let batch = Array(photos[currentIndex..<endIndex])
            
            for (offset, photo) in batch.enumerated() {
                let photoIndex = currentIndex + offset
                
                imageManager.requestImage(
                    for: photo.asset,
                    targetSize: thumbnailSize,
                    contentMode: .aspectFill,
                    options: options
                ) { image, _ in
                    DispatchQueue.main.async {
                        if photoIndex < self.photos.count {
                            self.photos[photoIndex].thumbnail = image
                        }
                    }
                }
            }
            
            currentIndex = endIndex
            
            if currentIndex < totalPhotos {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    loadNextBatch()
                }
            }
        }
        
        loadNextBatch()
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
        
        let assetsToDelete = photos.filter { selectedPhotos.contains($0.id) }.map { $0.asset }
        
        DispatchQueue.main.async {
            self.isDeleting = true
        }
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
        }) { success, error in
            DispatchQueue.main.async {
                self.isDeleting = false
                
                if success {
                    self.photos.removeAll { self.selectedPhotos.contains($0.id) }
                    self.selectedPhotos.removeAll()
                } else {
                    self.errorMessage = error?.localizedDescription ?? "Failed to delete photos. Please ensure you have granted full photo library access in Settings > Privacy & Security > Photos."
                    self.showError = true
                }
            }
        }
    }
}
import SwiftUI
import CryptoKit

struct DuplicateFileScannerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = DuplicateFileViewModel()
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()
            
            if viewModel.isScanning {
                loadingView
            } else if viewModel.duplicateGroups.isEmpty {
                emptyStateView
            } else {
                duplicateGroupsView
            }
            
            if viewModel.isDeleting {
                deletingOverlay
            }
        }
        .navigationTitle("Duplicate Files")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Files", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteSelectedFiles()
            }
        } message: {
            Text("Are you sure you want to delete \(viewModel.selectedFiles.count) file(s)? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .onAppear {
            themeManager.updateTheme()
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(themeManager.accentColor)
            
            Text("Scanning for Duplicates...")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            
            Text("Analyzed \(viewModel.scannedCount) files")
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
            Image(systemName: "doc.on.doc")
                .font(.system(size: 60))
                .foregroundColor(themeManager.secondaryText)
            
            Text(viewModel.hasScanned ? "No Duplicates Found" : "Scan for Duplicates")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
            
            Text(viewModel.hasScanned ? "Your files are clean!" : "Tap the button below to scan your documents for duplicate files")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                viewModel.scanForDuplicates()
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
                        DuplicateFileGroupCard(group: group, viewModel: viewModel)
                    }
                }
                .padding(.bottom, 100)
            }
            
            VStack(spacing: 12) {
                if !viewModel.selectedFiles.isEmpty {
                    HStack {
                        Text("\(viewModel.selectedFiles.count) file(s) selected")
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
                        viewModel.scanForDuplicates()
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
                        if !viewModel.selectedFiles.isEmpty {
                            showDeleteConfirmation = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(viewModel.selectedFiles.isEmpty ? themeManager.secondaryText : themeManager.buttonText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(viewModel.selectedFiles.isEmpty ? themeManager.borderColor : themeManager.errorColor)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedFiles.isEmpty)
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
                
                Text("Deleting Files...")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.white)
            }
            .padding(40)
            .background(themeManager.cardBackground)
            .cornerRadius(16)
        }
    }
}

struct DuplicateFileGroupCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let group: DuplicateFileGroup
    @ObservedObject var viewModel: DuplicateFileViewModel
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(themeManager.borderColor)
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: group.fileIcon)
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(group.files.count) Duplicates")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text(group.fileName)
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                            .lineLimit(1)
                        
                        Text("\(group.totalSize) MB")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
            
            if isExpanded {
                VStack(spacing: 8) {
                    ForEach(group.files) { file in
                        DuplicateFileItem(file: file, isSelected: viewModel.selectedFiles.contains(file.id)) {
                            viewModel.toggleFileSelection(file.id)
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

struct DuplicateFileItem: View {
    @EnvironmentObject var themeManager: ThemeManager
    let file: FileItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(isSelected ? themeManager.accentColor : themeManager.borderColor, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .fill(themeManager.accentColor)
                        .frame(width: 16, height: 16)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(file.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
                
                Text(file.path)
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text(file.sizeString)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .padding(12)
        .background(isSelected ? themeManager.accentColor.opacity(0.1) : themeManager.background)
        .cornerRadius(8)
        .onTapGesture {
            onTap()
        }
    }
}

struct DuplicateFileGroup: Identifiable {
    let id = UUID()
    let hash: String
    var files: [FileItem]
    var totalSize: String
    var fileName: String
    var fileIcon: String
}

struct FileItem: Identifiable {
    let id: String
    let url: URL
    let name: String
    let path: String
    let size: Int64
    var sizeString: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

class DuplicateFileViewModel: ObservableObject {
    @Published var duplicateGroups: [DuplicateFileGroup] = []
    @Published var selectedFiles: Set<String> = []
    @Published var isScanning = false
    @Published var isDeleting = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var scannedCount = 0
    @Published var hasScanned = false
    
    var totalDuplicateSize: String {
        let total = duplicateGroups.reduce(0.0) { sum, group in
            sum + (Double(group.totalSize.replacingOccurrences(of: " MB", with: "")) ?? 0.0)
        }
        return String(format: "%.1f", total)
    }
    
    func scanForDuplicates() {
        DispatchQueue.main.async {
            self.isScanning = true
            self.duplicateGroups = []
            self.selectedFiles = []
            self.scannedCount = 0
            self.hasScanned = false
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var filesByHash: [String: [FileItem]] = [:]
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            self.scanDirectory(url: documentsURL, filesByHash: &filesByHash)
            
            DispatchQueue.main.async {
                var duplicates: [DuplicateFileGroup] = []
                
                for (hash, files) in filesByHash {
                    if files.count > 1 {
                        let totalBytes = files.reduce(0) { $0 + $1.size }
                        let totalMB = String(format: "%.1f", Double(totalBytes) / 1_000_000)
                        
                        let fileName = files.first?.name ?? "Unknown"
                        let fileIcon = self.getFileIcon(for: fileName)
                        
                        let group = DuplicateFileGroup(
                            hash: hash,
                            files: files,
                            totalSize: totalMB,
                            fileName: fileName,
                            fileIcon: fileIcon
                        )
                        duplicates.append(group)
                    }
                }
                
                self.duplicateGroups = duplicates.sorted { $0.files.count > $1.files.count }
                self.isScanning = false
                self.hasScanned = true
            }
        }
    }
    
    private func scanDirectory(url: URL, filesByHash: inout [String: [FileItem]]) {
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else { return }
        
        for case let fileURL as URL in enumerator {
            do {
                let resourceValues = try fileURL.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
                
                guard let isRegularFile = resourceValues.isRegularFile, isRegularFile else {
                    continue
                }
                
                DispatchQueue.main.async {
                    self.scannedCount += 1
                }
                
                guard let fileSize = resourceValues.fileSize, fileSize > 0 else {
                    continue
                }
                
                if let data = try? Data(contentsOf: fileURL) {
                    let hash = self.hashFileData(data)
                    
                    let fileItem = FileItem(
                        id: fileURL.path,
                        url: fileURL,
                        name: fileURL.lastPathComponent,
                        path: fileURL.path.replacingOccurrences(of: NSHomeDirectory(), with: "~"),
                        size: Int64(fileSize)
                    )
                    
                    if filesByHash[hash] != nil {
                        filesByHash[hash]?.append(fileItem)
                    } else {
                        filesByHash[hash] = [fileItem]
                    }
                }
            } catch {
                continue
            }
        }
    }
    
    private func hashFileData(_ data: Data) -> String {
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func getFileIcon(for fileName: String) -> String {
        let ext = (fileName as NSString).pathExtension.lowercased()
        
        switch ext {
        case "pdf":
            return "doc.text"
        case "doc", "docx":
            return "doc.text"
        case "xls", "xlsx":
            return "tablecells"
        case "ppt", "pptx":
            return "rectangle.on.rectangle"
        case "txt":
            return "doc.plaintext"
        case "zip", "rar", "7z":
            return "doc.zipper"
        case "mp3", "wav", "m4a":
            return "music.note"
        case "mp4", "mov", "avi":
            return "video"
        default:
            return "doc"
        }
    }
    
    func toggleFileSelection(_ id: String) {
        if selectedFiles.contains(id) {
            selectedFiles.remove(id)
        } else {
            selectedFiles.insert(id)
        }
    }
    
    func clearSelection() {
        selectedFiles.removeAll()
    }
    
    func deleteSelectedFiles() {
        guard !selectedFiles.isEmpty else { return }
        
        DispatchQueue.main.async {
            self.isDeleting = true
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            var deletedFiles: Set<String> = []
            var hasError = false
            var errorMsg = ""
            
            for groupIndex in 0..<self.duplicateGroups.count {
                for file in self.duplicateGroups[groupIndex].files {
                    if self.selectedFiles.contains(file.id) {
                        do {
                            try FileManager.default.removeItem(at: file.url)
                            deletedFiles.insert(file.id)
                        } catch {
                            hasError = true
                            errorMsg = error.localizedDescription
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                self.isDeleting = false
                
                if hasError {
                    self.errorMessage = errorMsg
                    self.showError = true
                }
                
                for (groupIndex, group) in self.duplicateGroups.enumerated().reversed() {
                    self.duplicateGroups[groupIndex].files.removeAll { deletedFiles.contains($0.id) }
                    
                    if self.duplicateGroups[groupIndex].files.count <= 1 {
                        self.duplicateGroups.remove(at: groupIndex)
                    }
                }
                
                self.selectedFiles.removeAll()
            }
        }
    }
}
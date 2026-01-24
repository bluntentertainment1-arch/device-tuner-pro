import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @State private var selectedTheme: ThemeManager.ThemeMode
    @State private var showHowToUse = false
    
    init() {
        _selectedTheme = State(initialValue: ThemeManager.shared.themeMode)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        themeSelectionCard
                        
                        howToUseCard
                        
                        aboutCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.secondaryText)
                }
            )
            .sheet(isPresented: $showHowToUse) {
                HowToUseView()
            }
        }
        .accentColor(themeManager.navigationText)
        .onAppear {
            selectedTheme = themeManager.themeMode
        }
    }
    
    private var themeSelectionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Appearance")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(ThemeManager.ThemeMode.allCases, id: \.self) { mode in
                    themeOptionRow(mode: mode)
                }
            }
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func themeOptionRow(mode: ThemeManager.ThemeMode) -> some View {
        Button(action: {
            selectedTheme = mode
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                themeManager.setThemeMode(mode)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                themeManager.objectWillChange.send()
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(themeManager.accentColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: iconForMode(mode))
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.accentColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.rawValue)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(descriptionForMode(mode))
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                if selectedTheme == mode {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(themeManager.accentColor)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(16)
            .background(
                selectedTheme == mode ? 
                themeManager.accentColor.opacity(0.1) : 
                themeManager.background
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        selectedTheme == mode ? 
                        themeManager.accentColor : 
                        themeManager.borderColor,
                        lineWidth: selectedTheme == mode ? 2 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func iconForMode(_ mode: ThemeManager.ThemeMode) -> String {
        switch mode {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "circle.lefthalf.filled"
        }
    }
    
    private func descriptionForMode(_ mode: ThemeManager.ThemeMode) -> String {
        switch mode {
        case .light:
            return "Always use light theme"
        case .dark:
            return "Always use dark theme"
        case .system:
            return "Match system settings"
        }
    }
    
    private var howToUseCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Help")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            Button(action: {
                showHowToUse = true
            }) {
                HStack(spacing: 16) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 40, height: 40)
                        .background(themeManager.accentColor.opacity(0.1))
                        .cornerRadius(10)
                    
                    Text("How to Use")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding(16)
                .background(themeManager.background)
                .cornerRadius(12)
            }
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var aboutCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("About")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                Spacer()
            }
            
            VStack(spacing: 12) {
                urlButton(
                    icon: "lock.shield.fill",
                    title: "Privacy Policy",
                    url: "https://bluntentertainment1-arch.github.io/Device-Tuner-Pro-26/privacy-policy.html"
                )
            }
            
            Text("© 2025 Blunt Entertainment. All rights reserved.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(20)
        .background(themeManager.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func urlButton(icon: String, title: String, url: String) -> some View {
        Button(action: {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 40, height: 40)
                    .background(themeManager.accentColor.opacity(0.1))
                    .cornerRadius(10)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.secondaryText)
            }
            .padding(16)
            .background(themeManager.background)
            .cornerRadius(12)
        }
    }
}
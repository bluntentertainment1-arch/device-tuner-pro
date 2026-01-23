import SwiftUI

struct AboutView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        Image(systemName: "sparkles.rectangle.stack.fill")
                            .font(.system(size: 60))
                            .foregroundColor(themeManager.accentColor)
                            .padding(.top, 20)
                        
                        Text("Device Tuner PRO 26")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text("Version 1.0.0")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                        
                        VStack(spacing: 12) {
                            urlButton(
                                icon: "lock.shield.fill",
                                title: "Privacy Policy",
                                url: "https://bluntentertainment1-arch.github.io/Device-Tuner-Pro-26/privacy-policy.html"
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Text("© 2025 Blunt Entertainment. All rights reserved.")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitle("About", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(themeManager.secondaryText)
                }
            )
        }
        .accentColor(themeManager.navigationText)
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
            .background(themeManager.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}
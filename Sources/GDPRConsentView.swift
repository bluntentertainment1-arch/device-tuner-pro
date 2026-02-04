import SwiftUI

struct GDPRConsentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool
    let onAccept: () -> Void
    let onDecline: () -> Void
    
    @State private var hasScrolledToBottom = false
    @State private var scrollViewContentHeight: CGFloat = 0
    @State private var scrollViewVisibleHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            introductionSection
                            
                            dataCollectionSection
                            
                            dataUsageSection
                            
                            dataStorageSection
                            
                            yourRightsSection
                            
                            contactSection
                            
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                        .padding(24)
                        .background(
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ScrollViewHeightPreferenceKey.self, value: geometry.size.height)
                            }
                        )
                    }
                    .frame(maxHeight: 400)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollViewVisibleHeightPreferenceKey.self, value: geometry.size.height)
                        }
                    )
                    .onPreferenceChange(ScrollViewHeightPreferenceKey.self) { height in
                        scrollViewContentHeight = height
                        checkIfScrolledToBottom()
                    }
                    .onPreferenceChange(ScrollViewVisibleHeightPreferenceKey.self) { height in
                        scrollViewVisibleHeight = height
                        checkIfScrolledToBottom()
                    }
                    .onChange(of: scrollViewContentHeight) { _ in
                        checkIfScrolledToBottom()
                    }
                }
                
                buttonsView
            }
            .frame(maxWidth: 500)
            .background(themeManager.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                
                Text("Privacy & Data Protection")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                
                Spacer()
            }
            
            Text("GDPR Compliance Notice")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(24)
        .background(themeManager.background)
    }
    
    private var introductionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome to Device Tuner PRO 26")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(themeManager.primaryText)
            
            Text("We respect your privacy and are committed to protecting your personal data. This notice explains how we collect, use, and safeguard your information in compliance with the UK General Data Protection Regulation (UK GDPR).")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var dataCollectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "doc.text.magnifyingglass")
                    .foregroundColor(themeManager.accentColor)
                Text("Data We Collect")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Device information (model, OS version, language)")
                bulletPoint("App usage analytics (launch count, feature usage)")
                bulletPoint("Unique device identifier (for analytics purposes only)")
                bulletPoint("Performance metrics (battery level, storage usage)")
            }
            
            Text("We do NOT collect:")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Personal identification information (name, email, phone)")
                bulletPoint("Location data")
                bulletPoint("Photo or media content")
                bulletPoint("Contacts or messages")
            }
        }
    }
    
    private var dataUsageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.2")
                    .foregroundColor(themeManager.accentColor)
                Text("How We Use Your Data")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("To improve app performance and user experience")
                bulletPoint("To analyze app usage patterns and optimize features")
                bulletPoint("To provide personalized recommendations")
                bulletPoint("To display relevant advertisements (via Google AdMob)")
            }
            
            Text("Legal Basis: Legitimate interests in improving our services and your consent for analytics.")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .italic()
                .padding(.top, 8)
        }
    }
    
    private var dataStorageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lock.shield")
                    .foregroundColor(themeManager.accentColor)
                Text("Data Storage & Security")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Data is stored securely on servers located in the EU/UK")
                bulletPoint("We use industry-standard encryption protocols")
                bulletPoint("Data is retained for a maximum of 24 months")
                bulletPoint("Third-party services (Google AdMob) may process data according to their privacy policies")
            }
        }
    }
    
    private var yourRightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "person.badge.shield.checkmark")
                    .foregroundColor(themeManager.accentColor)
                Text("Your Rights Under UK GDPR")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                bulletPoint("Right to access your personal data")
                bulletPoint("Right to rectification of inaccurate data")
                bulletPoint("Right to erasure ('right to be forgotten')")
                bulletPoint("Right to restrict processing")
                bulletPoint("Right to data portability")
                bulletPoint("Right to object to processing")
                bulletPoint("Right to withdraw consent at any time")
            }
            
            Text("To exercise any of these rights, please contact us using the information below.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .padding(.top, 8)
        }
    }
    
    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "envelope")
                    .foregroundColor(themeManager.accentColor)
                Text("Contact & More Information")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
            }
            
            Text("Data Controller: Blunt Entertainment")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.primaryText)
            
            Button(action: {
                if let url = URL(string: "https://bluntentertainment1-arch.github.io/Device-Tuner-Pro-26/privacy-policy.html") {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack {
                    Text("View Full Privacy Policy")
                        .font(.system(size: 14, weight: .medium))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12))
                }
                .foregroundColor(themeManager.accentColor)
            }
            .padding(.top, 4)
            
            Text("Last Updated: January 2025")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .padding(.top, 8)
        }
    }
    
    private var buttonsView: some View {
        VStack(spacing: 12) {
            if !hasScrolledToBottom {
                HStack {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 12))
                    Text("Please scroll to read all terms")
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(themeManager.warningColor)
                .padding(.vertical, 8)
            }
            
            Button(action: {
                onAccept()
                isPresented = false
            }) {
                Text("Accept & Continue")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        hasScrolledToBottom ? 
                        LinearGradient(
                            colors: [themeManager.accentColor, themeManager.electricPink],
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
            }
            .disabled(!hasScrolledToBottom)
            
            Button(action: {
                onDecline()
                isPresented = false
            }) {
                Text("Decline")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
            }
        }
        .padding(24)
        .background(themeManager.background)
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(themeManager.accentColor)
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private func checkIfScrolledToBottom() {
        if scrollViewContentHeight > 0 && scrollViewVisibleHeight > 0 {
            hasScrolledToBottom = scrollViewContentHeight <= scrollViewVisibleHeight + 50
        }
    }
}

struct ScrollViewHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ScrollViewVisibleHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
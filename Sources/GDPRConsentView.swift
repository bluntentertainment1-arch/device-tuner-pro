import SwiftUI
import GoogleMobileAds

struct GDPRConsentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var isPresented: Bool

    let onAccept: () -> Void
    let onDecline: () -> Void

    @State private var hasScrolledToBottom = false
    @State private var contentHeight: CGFloat = 0
    @State private var visibleHeight: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        introductionSection
                        dataCollectionSection
                        dataUsageSection
                        dataStorageSection
                        rightsSection
                        contactSection

                        Color.clear.frame(height: 1)
                    }
                    .padding(24)
                    .background(
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ContentHeightKey.self, value: geo.size.height)
                        }
                    )
                }
                .frame(maxHeight: 420)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: VisibleHeightKey.self, value: geo.size.height)
                    }
                )
                .onPreferenceChange(ContentHeightKey.self) { contentHeight = $0 }
                .onPreferenceChange(VisibleHeightKey.self) { visibleHeight = $0 }
                .onChange(of: contentHeight) { _ in checkScroll() }
                .onChange(of: visibleHeight) { _ in checkScroll() }

                buttonsView
            }
            .frame(maxWidth: 520)
            .background(themeManager.cardBackground)
            .cornerRadius(20)
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "shield.checkered")
                    .foregroundColor(themeManager.accentColor)
                Text("Privacy & Data Protection")
                    .font(.headline)
                Spacer()
            }

            Text("GDPR Compliance Notice")
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
        }
        .padding(20)
        .background(themeManager.background)
    }

    // MARK: - Sections
    private var introductionSection: some View {
        section(
            title: "Welcome to Device Tuner PRO 26",
            body: "We respect your privacy. This notice explains how your data is processed in accordance with GDPR."
        )
    }

    private var dataCollectionSection: some View {
        section(
            title: "Data We Collect",
            body:
            """
            • Device information (model, OS)
            • App usage analytics
            • Performance metrics

            We do NOT collect personal data such as photos, contacts, or location.
            """
        )
    }

    private var dataUsageSection: some View {
        section(
            title: "How We Use Data",
            body:
            """
            • Improve app performance
            • Analyze usage trends
            • Display advertisements (Google AdMob)
            """
        )
    }

    private var dataStorageSection: some View {
        section(
            title: "Storage & Security",
            body:
            """
            • Data processed securely
            • Stored according to Google policies
            • Retained for limited periods only
            """
        )
    }

    private var rightsSection: some View {
        section(
            title: "Your Rights",
            body:
            """
            • Access
            • Erasure
            • Withdraw consent anytime
            """
        )
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact & Policy")
                .font(.headline)

            Button {
                if let url = URL(string: "https://bluntentertainment1-arch.github.io/Device-Tuner-Pro-26/privacy-policy.html") {
                    UIApplication.shared.open(url)
                }
            } label: {
                Label("View Privacy Policy", systemImage: "arrow.up.right")
            }
            .foregroundColor(themeManager.accentColor)
        }
    }

    // MARK: - Buttons
    private var buttonsView: some View {
        VStack(spacing: 12) {
            if !hasScrolledToBottom {
                Text("Please scroll to read all information")
                    .font(.caption)
                    .foregroundColor(themeManager.warningColor)
            }

            Button {
                saveConsent(granted: true)
                onAccept()
                isPresented = false
            } label: {
                Text("Accept & Continue")
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(hasScrolledToBottom ? themeManager.accentColor : themeManager.borderColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(!hasScrolledToBottom)

            Button {
                saveConsent(granted: false)
                onDecline()
                isPresented = false
            } label: {
                Text("Decline")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .foregroundColor(themeManager.secondaryText)
        }
        .padding(20)
        .background(themeManager.background)
    }

    // MARK: - Helpers
    private func saveConsent(granted: Bool) {
        UserDefaults.standard.set(granted, forKey: "gdpr_consent_granted")

        let config = GADMobileAds.sharedInstance.requestConfiguration

        if !granted {
            config.maxAdContentRating = GADMaxAdContentRating.general
        }

        GADMobileAds.sharedInstance.start { _ in
            // Optional: perform any action after initialization
        }
    }

    private func checkScroll() {
        if contentHeight > 0 && visibleHeight > 0 {
            hasScrolledToBottom = contentHeight <= visibleHeight + 40
        }
    }

    private func section(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundColor(themeManager.secondaryText)
        }
    }
}

// MARK: - Preference Keys
private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct VisibleHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

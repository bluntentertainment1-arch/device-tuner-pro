import SwiftUI

struct WalkthroughView: View {
    @EnvironmentObject var themeManager: ThemeManager

    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false
    @AppStorage("hasAcceptedGDPR") private var hasAcceptedGDPR = false

    @State private var currentPage = 0
    @State private var showGDPRConsent = false

    private let walkthroughPages = [
        WalkthroughPage(
            title: "Clean Your Device",
            description: "Remove unwanted photos to free up valuable storage space",
            icon: "trash.circle.fill"
        ),
        WalkthroughPage(
            title: "Manage Performance",
            description: "Monitor your device speed and temperature with smart management tools",
            icon: "speedometer"
        ),
        WalkthroughPage(
            title: "Monitor Battery Usage",
            description: "Monitor battery usage with intelligent power management",
            icon: "battery.100.bolt"
        )
    ]

    var body: some View {
        ZStack {
            themeManager.background.ignoresSafeArea()

            VStack(spacing: 0) {
                walkthroughPagesView
                controlsView
            }

            SparklingStarsView()

            if showGDPRConsent {
                GDPRConsentView(
                    isPresented: $showGDPRConsent,
                    onAccept: {
                        hasAcceptedGDPR = true
                        UserDefaults.standard.set(Date(), forKey: "gdprConsentDate")
                        hasSeenWalkthrough = true
                    },
                    onDecline: {
                        hasAcceptedGDPR = false
                        hasSeenWalkthrough = true
                        // App continues with non-personalized ads
                    }
                )
                .zIndex(1000)
            }
        }
        .onAppear {
            themeManager.updateTheme()
        }
    }

    // MARK: - Views

    private var walkthroughPagesView: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<walkthroughPages.count, id: \.self) { index in
                WalkthroughPageView(page: walkthroughPages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }

    private var controlsView: some View {
        VStack(spacing: 24) {
            pageIndicator
            navigationButtons
            skipButton
        }
        .padding(.bottom, 40)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<walkthroughPages.count, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? themeManager.accentColor : themeManager.borderColor)
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentPage > 0 {
                Button("Previous") {
                    withAnimation { currentPage -= 1 }
                }
                .secondaryButton(themeManager)
            }

            Button(currentPage < walkthroughPages.count - 1 ? "Next" : "Get Started") {
                handleFinish()
            }
            .primaryButton(themeManager)
        }
        .padding(.horizontal, 24)
    }

    private var skipButton: some View {
        Group {
            if currentPage < walkthroughPages.count - 1 {
                Button("Skip") {
                    handleFinish()
                }
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Logic

    private func handleFinish() {
        if requiresGDPRConsent() && !hasAcceptedGDPR {
            showGDPRConsent = true
        } else {
            hasSeenWalkthrough = true
        }
    }

    private func requiresGDPRConsent() -> Bool {
        guard let region = Locale.current.region?.identifier else { return false }
        let gdprRegions = ["GB","UK","DE","FR","IT","ES","NL","BE","SE","FI","DK","NO","IE","AT","PL","PT","RO","CZ","HU","GR"]
        return gdprRegions.contains(region)
    }
}

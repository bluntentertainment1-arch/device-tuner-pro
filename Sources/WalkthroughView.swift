import SwiftUI

struct WalkthroughView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false
    @AppStorage("hasAcceptedGDPR") private var hasAcceptedGDPR = false
    @State private var currentPage = 0
    @State private var showGDPRConsent = false
    @State private var shouldCheckGDPR = true
    
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
            themeManager.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<walkthroughPages.count, id: \.self) { index in
                        WalkthroughPageView(page: walkthroughPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<walkthroughPages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? themeManager.accentColor : themeManager.borderColor)
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                Text("Previous")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(themeManager.cardBackground)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeManager.borderColor, lineWidth: 1)
                                    )
                            }
                        }
                        
                        Button(action: {
                            if currentPage < walkthroughPages.count - 1 {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                if isUKUser() && !hasAcceptedGDPR {
                                    showGDPRConsent = true
                                } else {
                                    hasSeenWalkthrough = true
                                }
                            }
                        }) {
                            Text(currentPage < walkthroughPages.count - 1 ? "Next" : "Get Started")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.buttonText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(themeManager.buttonBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    if currentPage < walkthroughPages.count - 1 {
                        Button(action: {
                            if isUKUser() && !hasAcceptedGDPR {
                                showGDPRConsent = true
                            } else {
                                hasSeenWalkthrough = true
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.bottom, 40)
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
                        exit(0)
                    }
                )
                .transition(.opacity)
                .zIndex(1000)
            }
        }
        .onAppear {
            themeManager.updateTheme()
            
            if shouldCheckGDPR && isUKUser() && !hasAcceptedGDPR {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showGDPRConsent = true
                    shouldCheckGDPR = false
                }
            }
        }
    }
    
    private func isUKUser() -> Bool {
        let regionCode = Locale.current.region?.identifier ?? ""
        return regionCode == "GB" || regionCode == "UK"
    }
}

struct WalkthroughPage {
    let title: String
    let description: String
    let icon: String
}

struct WalkthroughPageView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let page: WalkthroughPage
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(themeManager.accentColor)
                .padding(.bottom, 20)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}
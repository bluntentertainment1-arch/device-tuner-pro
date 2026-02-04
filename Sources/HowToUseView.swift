import SwiftUI

// MARK: - HowToUseView

struct HowToUseView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasSeenWalkthrough") private var hasSeenWalkthrough = false
    @AppStorage("hasAcceptedGDPR") private var hasAcceptedGDPR = false
    @State private var currentStep = 0
    @State private var showGDPRConsent = false
    @State private var shouldCheckGDPR = true

    private let steps = [
        HowToUseStep(
            number: "1",
            title: "Refresh Your Device Status",
            description: "Start by opening the dashboard and refreshing your device status.\n\nThis helps you understand your current device status and system information.",
            icon: "gauge.high",
            color: Color(red: 0.5, green: 0.3, blue: 0.85)
        ),
        HowToUseStep(
            number: "2",
            title: "Turn On Battery Saving",
            description: "Open Battery Saving to view battery usage and remaining time.\n\nYou can also access system battery settings and review simple usage tips.",
            icon: "battery.100.bolt",
            color: Color(red: 0.6, green: 0.4, blue: 0.9)
        ),
        HowToUseStep(
            number: "3",
            title: "Enable Gaming Mode",
            description: "Before playing games, open Gaming Mode.\n\nFrom here, you can monitor device behavior during gameplay and close unused background apps.",
            icon: "gamecontroller.fill",
            color: Color(red: 0.7, green: 0.5, blue: 0.95)
        ),
        HowToUseStep(
            number: "Optional",
            title: "Optional Steps",
            description: "• Photo Cleanup\nReview duplicate or similar photos and remove the ones you no longer need to free up storage.\n\n• CPU Performance Monitoring\nCheck CPU activity to stay informed about device performance during regular use or gaming.",
            icon: "star.fill",
            color: Color(red: 0.6, green: 0.2, blue: 0.9)
        )
    ]

    var body: some View {
        ZStack {
            themeManager.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                headerView

                TabView(selection: $currentStep) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        HowToUseStepView(step: steps[index], isOptionalStep: steps[index].number == "Optional")
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

                VStack(spacing: 24) {
                    HStack(spacing: 8) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Circle()
                                .fill(currentStep == index ? themeManager.accentColor : themeManager.borderColor)
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentStep)
                        }
                    }

                    if currentStep == steps.count - 1 {
                        importantNoteCard
                    }

                    HStack(spacing: 16) {
                        if currentStep > 0 {
                            Button(action: {
                                withAnimation {
                                    currentStep -= 1
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
                            if currentStep < steps.count - 1 {
                                withAnimation {
                                    currentStep += 1
                                }
                            } else {
                                // ✅ GDPR check before finishing walkthrough
                                if isEEAOrUKUser() && !hasAcceptedGDPR {
                                    showGDPRConsent = true
                                } else {
                                    hasSeenWalkthrough = true
                                    dismiss()
                                }
                            }
                        }) {
                            Text(currentStep < steps.count - 1 ? "Next" : "Continue to Dashboard")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(themeManager.buttonText)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(themeManager.buttonBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 24)
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
                        dismiss()
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
        .navigationBarHidden(true)
        .onAppear {
            themeManager.updateTheme()

            if shouldCheckGDPR && isEEAOrUKUser() && !hasAcceptedGDPR {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showGDPRConsent = true
                    shouldCheckGDPR = false
                }
            }
        }
    }

    // MARK: - Header

    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button(action: {
                    hasSeenWalkthrough = true
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding(.trailing, 20)
                .padding(.top, 16)
            }

            Text("How to Use Device Tuner Pro 26")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
        }
    }

    // MARK: - Important Note Card

    private var importantNoteCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.accentColor)

                Text("Important Note")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Spacer()
            }

            Text("Device Tuner Pro 26 does not make automatic system changes.\n\nAll actions require user interaction and can be adjusted or reversed through system settings.")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(themeManager.cardBackground)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.borderColor, lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }

    // MARK: - EEA / UK detection

    private func isEEAOrUKUser() -> Bool {
        let eeaCountries = ["AT","BE","BG","HR","CY","CZ","DK","EE","FI","FR","DE",
                            "GR","HU","IS","IE","IT","LV","LI","LT","LU","MT","NL",
                            "NO","PL","PT","RO","SK","SI","ES","SE","GB"]
        let region = Locale.current.region?.identifier ?? ""
        return eeaCountries.contains(region)
    }
}

// MARK: - HowToUseStep

struct HowToUseStep {
    let number: String
    let title: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - HowToUseStepView

struct HowToUseStepView: View {
    @EnvironmentObject var themeManager: ThemeManager
    let step: HowToUseStep
    let isOptionalStep: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                Spacer().frame(height: 20)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [step.color, step.color.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: step.color.opacity(0.6), radius: 20)
                        .shadow(color: step.color.opacity(0.3), radius: 30)

                    Image(systemName: step.icon)
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                .padding(.bottom, 20)

                VStack(spacing: 16) {
                    HStack {
                        Text("Step \(step.number)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(step.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(step.color.opacity(0.15))
                            .cornerRadius(20)

                        Spacer()
                    }
                    .padding(.horizontal, 40)

                    Text(step.title)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    Text(step.description)
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(6)
                        .padding(.horizontal, 40)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
        }
    }
}

import Foundation
import SwiftUI
import GoogleMobileAds

@MainActor
class AdManager: NSObject, ObservableObject {

    static let shared = AdManager()

    @Published var isShowingRewardedAd = false
    @Published var isLoadingRewardedAd = false
    @Published var rewardedAdError: String? = nil
    @Published var bannerViewHeight: CGFloat = 50
    @Published var showAdLoadingMessage = false
    @Published var rewardedAdFailureMessage: String? = nil

    let bannerAdUnitID = "ca-app-pub-3940256099942544/2934735716"
    private let rewardedAdUnitID = "ca-app-pub-3940256099942544/1712485313"
    private let interstitialAdUnitID = "ca-app-pub-3940256099942544/4411468910"

    private var rewardedAd: RewardedAd?
    private var interstitialAd: InterstitialAd?
    private var rewardedAdCompletion: ((Bool) -> Void)?

    private override init() {
        super.init()
        loadRewardedAd()
        loadInterstitialAd()
    }

    // MARK: - Rewarded Ad

    func loadRewardedAd() {
        isLoadingRewardedAd = true
        rewardedAdError = nil
        rewardedAdFailureMessage = nil

        let request = Request()
        RewardedAd.load(with: rewardedAdUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }

            self.isLoadingRewardedAd = false

            if let error {
                print("❌ Failed to load rewarded ad: \(error.localizedDescription)")
                self.rewardedAdError = error.localizedDescription
                self.rewardedAdFailureMessage = "Unable to load ad. Try again later."
                return
            }

            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            print("✅ Rewarded ad loaded")
        }
    }

    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard let rewardedAd else {
            rewardedAdFailureMessage = "Ad is not ready yet."
            completion(false)
            loadRewardedAd()
            return
        }

        guard let rootVC = topViewController() else {
            rewardedAdFailureMessage = "Unable to display ad."
            completion(false)
            return
        }

        rewardedAdCompletion = completion
        rewardedAd.present(from: rootVC) { [weak self] in
            guard let self else { return }
            print("🎁 User earned reward")
            self.rewardedAdCompletion?(true)
            self.rewardedAdCompletion = nil
        }
    }

    // MARK: - Interstitial Ad

    func loadInterstitialAd() {
        let request = Request()
        InterstitialAd.load(with: interstitialAdUnitID, request: request) { [weak self] ad, error in
            guard let self else { return }

            if let error {
                print("❌ Failed to load interstitial: \(error.localizedDescription)")
                return
            }

            self.interstitialAd = ad
            self.interstitialAd?.fullScreenContentDelegate = self
            print("✅ Interstitial ad loaded")
        }
    }

    func showInterstitialAd() {
        guard let interstitialAd else {
            loadInterstitialAd()
            return
        }

        guard let rootVC = topViewController() else { return }
        interstitialAd.present(from: rootVC)
    }

    // MARK: - Helper

    private func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
        else { return nil }

        var top = root
        while let presented = top.presentedViewController {
            top = presented
        }
        return top
    }
}

// MARK: - FullScreenContentDelegate

extension AdManager: FullScreenContentDelegate {

    nonisolated func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("ℹ️ Ad dismissed")

        Task { @MainActor in
            if ad is RewardedAd {
                self.loadRewardedAd()
            } else if ad is InterstitialAd {
                self.loadInterstitialAd()
            }
        }
    }

    nonisolated func ad(
        _ ad: FullScreenPresentingAd,
        didFailToPresentFullScreenContentWithError error: Error
    ) {
        print("❌ Ad failed to present: \(error.localizedDescription)")

        Task { @MainActor in
            if ad is RewardedAd {
                self.rewardedAdFailureMessage = "Failed to display ad."
                self.rewardedAdCompletion?(false)
                self.rewardedAdCompletion = nil
                self.loadRewardedAd()
            } else if ad is InterstitialAd {
                self.loadInterstitialAd()
            }
        }
    }
}

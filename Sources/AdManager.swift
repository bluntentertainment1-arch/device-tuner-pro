import Foundation
import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@MainActor
class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    
    @Published var isShowingRewardedAd = false
    @Published var isLoadingRewardedAd = false
    @Published var rewardedAdError: String? = nil
    @Published var bannerViewHeight: CGFloat = 50
    @Published var showAdLoadingMessage = false
    @Published var rewardedAdFailureMessage: String? = nil
    
    let bannerAdUnitID = "ca-app-pub-1819215492028258/3482526881"
    private let rewardedAdUnitID = "ca-app-pub-1819215492028258/1990509481"
    private let interstitialAdUnitID = "ca-app-pub-1819215492028258/7613343585"
    
    #if canImport(GoogleMobileAds)
    private var rewardedAd: GADRewardedAd?
    private var interstitialAd: GADInterstitialAd?
    #endif
    
    private var rewardedAdCompletion: ((Bool) -> Void)?
    
    private override init() {
        super.init()
        loadRewardedAd()
        loadInterstitialAd()
    }
    
    func loadRewardedAd() {
        #if canImport(GoogleMobileAds)
        isLoadingRewardedAd = true
        rewardedAdError = nil
        rewardedAdFailureMessage = nil
        
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID: rewardedAdUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                self.isLoadingRewardedAd = false
                
                if let error = error {
                    print("Failed to load rewarded ad: \(error.localizedDescription)")
                    self.rewardedAdError = error.localizedDescription
                    self.rewardedAdFailureMessage = "Unable to load ad at this time. Please try again later."
                    return
                }
                
                self.rewardedAd = ad
                self.rewardedAd?.fullScreenContentDelegate = self
                print("Rewarded ad loaded successfully")
            }
        }
        #else
        print("Google Mobile Ads SDK not found")
        rewardedAdFailureMessage = "Ad service is not available. Please try again later."
        #endif
    }
    
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        #if canImport(GoogleMobileAds)
        guard let rewardedAd = rewardedAd else {
            print("Rewarded ad not ready")
            rewardedAdFailureMessage = "Ad is not ready yet. Please try again in a moment."
            completion(false)
            loadRewardedAd()
            return
        }
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = windowScene?.windows.first?.rootViewController else {
            print("Root view controller not found")
            rewardedAdFailureMessage = "Unable to display ad. Please try again."
            completion(false)
            return
        }
        
        rewardedAdCompletion = completion
        rewardedAd.present(fromRootViewController: rootViewController) { [weak self] in
            guard let self = self else { return }
            print("User earned reward")
            Task { @MainActor in
                self.rewardedAdCompletion?(true)
                self.rewardedAdCompletion = nil
                self.loadRewardedAd()
            }
        }
        #else
        rewardedAdFailureMessage = "Ad service is not available. Please try again later."
        completion(false)
        #endif
    }
    
    func loadInterstitialAd() {
        #if canImport(GoogleMobileAds)
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            Task { @MainActor in
                if let error = error {
                    print("Failed to load interstitial ad: \(error.localizedDescription)")
                    return
                }
                
                self.interstitialAd = ad
                self.interstitialAd?.fullScreenContentDelegate = self
                print("Interstitial ad loaded successfully")
            }
        }
        #endif
    }
    
    func showInterstitialAd() {
        #if canImport(GoogleMobileAds)
        guard let interstitialAd = interstitialAd else {
            print("Interstitial ad not ready")
            loadInterstitialAd()
            return
        }
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = windowScene?.windows.first?.rootViewController else {
            print("Root view controller not found")
            return
        }
        
        interstitialAd.present(fromRootViewController: rootViewController)
        #endif
    }
}

#if canImport(GoogleMobileAds)
extension AdManager: GADFullScreenContentDelegate {
    nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad dismissed")
        Task { @MainActor in
            if ad is GADRewardedAd {
                AdManager.shared.loadRewardedAd()
            } else if ad is GADInterstitialAd {
                AdManager.shared.loadInterstitialAd()
            }
        }
    }
    
    nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        Task { @MainActor in
            if ad is GADRewardedAd {
                AdManager.shared.rewardedAdFailureMessage = "Failed to display ad. Please try again later."
                AdManager.shared.rewardedAdCompletion?(false)
                AdManager.shared.rewardedAdCompletion = nil
                AdManager.shared.loadRewardedAd()
            } else if ad is GADInterstitialAd {
                AdManager.shared.loadInterstitialAd()
            }
        }
    }
}
#endif
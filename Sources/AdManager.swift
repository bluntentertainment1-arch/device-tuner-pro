import Foundation
import SwiftUI

@MainActor
class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    
    @Published var isShowingRewardedAd = false
    @Published var isLoadingRewardedAd = false
    @Published var rewardedAdError: String?
    @Published var bannerViewHeight: CGFloat = 0
    @Published var showAdLoadingMessage = false
    
    let bannerAdUnitID = ""
    
    private override init() {
        super.init()
    }
    
    func loadRewardedAd() {
    }
    
    func showRewardedAd(completion: @escaping (Bool) -> Void) {
        completion(true)
    }
    
    func loadInterstitialAd() {
    }
    
    func showInterstitialAd() {
    }
}
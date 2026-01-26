import SwiftUI
import UIKit

struct BannerAdView: View {
    @EnvironmentObject var adManager: AdManager
    let adUnitID: String
    
    var body: some View {
        EmptyView()
            .frame(height: 0)
            .onAppear {
                adManager.bannerViewHeight = 0
            }
    }
}
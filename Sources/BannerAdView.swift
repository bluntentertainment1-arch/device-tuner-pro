import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    @EnvironmentObject var adManager: AdManager
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID

        // Get root view controller (iOS 13+ safe)
        if let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive }),
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            banner.rootViewController = rootVC
        }

        banner.delegate = context.coordinator

        let request = Request()
        banner.load(request)

        // Reload ad every 60 seconds
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            banner.load(request)
        }

        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No-op
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, BannerViewDelegate {
        let parent: BannerAdView

        init(_ parent: BannerAdView) {
            self.parent = parent
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("✅ Banner ad loaded")
            DispatchQueue.main.async {
                self.parent.adManager.bannerViewHeight = 50
            }
        }

        func bannerView(
            _ bannerView: BannerView,
            didFailToReceiveAdWithError error: Error
        ) {
            print("❌ Banner ad failed: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.parent.adManager.bannerViewHeight = 0
            }
        }
    }
}

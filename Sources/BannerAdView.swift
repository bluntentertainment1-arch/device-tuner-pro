import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#else
struct GADAdSize {
    static let banner = CGSize(width: 320, height: 50)
}
let GADAdSizeBanner = GADAdSize.banner
class GADRequest {}
protocol GADBannerViewDelegate {}
class GADBannerView: UIView {
    var adUnitID: String?
    var rootViewController: UIViewController?
    var delegate: GADBannerViewDelegate?
    init(adSize: CGSize) {
        super.init(frame: .zero)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func load(_ request: GADRequest) {}
}
#endif

struct BannerAdView: UIViewRepresentable {
    @EnvironmentObject var adManager: AdManager
    let adUnitID: String

    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID

        // Safely get the root view controller for iOS 13+
        if let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            banner.rootViewController = rootVC
        }

        banner.delegate = context.coordinator

        let request = GADRequest()
        banner.load(request)

        // Reload ad every 60 seconds
        Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
            banner.load(request)
        }

        return banner
    }

    func updateUIView(_ uiView: GADBannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, GADBannerViewDelegate {
        var parent: BannerAdView

        init(_ parent: BannerAdView) {
            self.parent = parent
        }

        func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
            print("Banner ad loaded successfully")
            DispatchQueue.main.async {
                self.parent.adManager.bannerViewHeight = 50
            }
        }

        func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
            print("Banner ad failed to load: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.parent.adManager.bannerViewHeight = 0
            }
        }
    }
}

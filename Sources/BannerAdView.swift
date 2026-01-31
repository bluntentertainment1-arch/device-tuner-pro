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
#if canImport(GoogleMobileAds)
		let banner = GADBannerView(adSize: GADAdSizeBanner)
#else
		let banner = GADBannerView(adSize: GADAdSizeBanner)
#endif
		banner.adUnitID = adUnitID
		
		// Get the key window safely on iOS 13+
if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })   // get all window scenes
            .flatMap({ $0.windows })                // get all windows in those scenes
            .first(where: { $0.isKeyWindow }),      // pick the key window
   let rootVC = window.rootViewController {       // get its root view controller
    // Now you can use rootVC safely
    rootVC.present(yourViewController, animated: true)
}
		banner.delegate = context.coordinator
		
		let request = GADRequest()
		banner.load(request)
		
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

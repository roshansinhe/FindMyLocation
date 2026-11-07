import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    /// Set `useProductionID = true` when releasing or testing live production ads.
    /// Defaults to `false` (Google Test Banner ID) to prevent policy violations while testing.
    var useProductionID: Bool = false

    /// Production Ad Unit ID from your AdMob account
    private let productionAdUnitID = "ca-app-pub-3211129747127107/2764594163"

    /// Google's official Test Banner Ad Unit ID for iOS
    private let testAdUnitID = "ca-app-pub-3940256099942544/2934735716"

    var adUnitID: String {
        useProductionID ? productionAdUnitID : testAdUnitID
    }

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.delegate = context.coordinator

        // Find current key root view controller safely
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("✅ [AdMob] Banner ad loaded successfully!")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("❌ [AdMob] Banner ad failed to load: \(error.localizedDescription)")
        }
    }
}

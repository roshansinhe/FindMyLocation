import SwiftUI
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    // Google Test Banner Unit ID
    var adUnitID: String = "ca-app-pub-3940256099942544/2934735716"

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        
        // Find current key root view controller safely
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

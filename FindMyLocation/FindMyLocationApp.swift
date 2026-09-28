import SwiftUI
import GoogleMobileAds

@main
struct FindMyLocationApp: App {
    init() {
        // Initialize Google Mobile Ads SDK using Swift syntax
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

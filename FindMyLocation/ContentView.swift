import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                // Header / Hero Section
                VStack(spacing: 12) {
                    Image(systemName: "location.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.blue)

                    Text("Where Am I?")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Tap below to discover your exact current location and share it.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Main Location Info Card
                VStack(spacing: 16) {
                    if locationManager.isLoading {
                        ProgressView("Fetching location...")
                            .padding()
                    } else if let address = locationManager.addressString, let loc = locationManager.location {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.red)
                                Text("Current Address")
                                    .font(.headline)
                            }
                            
                            Text(address)
                                .font(.body)
                                .foregroundColor(.primary)

                            Divider()

                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Latitude")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.5f", loc.coordinate.latitude))
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Longitude")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(String(format: "%.5f", loc.coordinate.longitude))
                                        .font(.callout)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    } else if let error = locationManager.errorMessage {
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    } else {
                        Text("Location data not loaded yet.")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding()
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        locationManager.requestLocationPermissionAndFetch()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text(locationManager.location == nil ? "Get My Location" : "Update Location")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }

                    if let shareText = shareableLocationText {
                        ShareLink(item: shareText) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Location Details")
                            }
                            .font(.headline)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)

                // AdMob Banner Unit Pinning to Bottom
                BannerAdView()
                    .frame(width: 320, height: 50)
                    .padding(.bottom, 8)
            }
            .navigationTitle("FindMyLocation")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var shareableLocationText: String? {
        guard let location = locationManager.location else { return nil }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let mapsURL = "https://maps.apple.com/?ll=\(lat),\(lon)"
        
        if let address = locationManager.addressString {
            return "I am currently at:\n\(address)\n\nCoordinates: \(lat), \(lon)\nMaps: \(mapsURL)"
        } else {
            return "My current coordinates:\n\(lat), \(lon)\nMaps: \(mapsURL)"
        }
    }
}

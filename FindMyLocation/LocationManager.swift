import Foundation
import CoreLocation
import MapKit
import Combine

@MainActor
final class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var addressString: String?
    @Published var cityName: String?
    @Published var countryName: String?
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var isLoading = false
    @Published var errorMessage: String?

    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocationPermissionAndFetch() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            errorMessage = "Location access is denied. Please enable it in Settings."
        case .authorizedWhenInUse, .authorizedAlways:
            fetchLocation()
        @unknown default:
            break
        }
    }

    func fetchLocation() {
        isLoading = true
        errorMessage = nil
        locationManager.requestLocation()
    }

    private func reverseGeocode(_ location: CLLocation) {
        Task {
            do {
                // MKReverseGeocodingRequest initializes with location: location and returns an optional
                guard let request = MKReverseGeocodingRequest(location: location) else {
                    self.isLoading = false
                    self.errorMessage = "Unable to create reverse geocoding request."
                    return
                }
                
                let mapItems = try await request.mapItems
                
                guard let mapItem = mapItems.first else {
                    self.isLoading = false
                    self.errorMessage = "No address found for location."
                    return
                }
                
                let placemark = mapItem.placemark
                self.cityName = placemark.locality ?? placemark.subAdministrativeArea
                self.countryName = placemark.country
                
                let components = [
                    placemark.name,
                    placemark.subLocality,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.postalCode,
                    placemark.country
                ].compactMap { $0 }

                self.addressString = components.joined(separator: ", ")
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = "Unable to fetch address details: \(error.localizedDescription)"
            }
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            fetchLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        reverseGeocode(location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLoading = false
        errorMessage = "Failed to locate device: \(error.localizedDescription)"
    }
}

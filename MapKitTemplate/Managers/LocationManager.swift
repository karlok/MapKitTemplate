//
//  LocationManager.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-24.
//

import CoreLocation
import Combine

enum MapLoadingState {
    case idle
    case loading
    case loaded
    case failed(Error)
}

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var loadingState: MapLoadingState = .idle
    @Published var currentLocation: CLLocation?
    @Published var locationPermissionDenied = false
    
    private let locationManager = CLLocationManager()
    private let errorManager: ErrorManager
    
    init(errorManager: ErrorManager) {
        self.errorManager = errorManager
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        // Request authorization only once
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocationAccess() {
        // If already authorized, start updating; otherwise, request authorization
        let status = self.locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            loadingState = .loading
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
}

// MARK: - delegate functions
extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentLocation = location
            self.loadingState = .loaded
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.loadingState = .failed(error)
            self.errorManager.showError(error.localizedDescription)
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Task { @MainActor in
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
                self.locationPermissionDenied = false
            case .denied, .restricted:
                let error = AppError.locationAccessDenied
                self.loadingState = .failed(error)
                self.errorManager.showError(error.localizedDescription)
                self.locationPermissionDenied = true
            case .notDetermined:
                self.locationManager.requestWhenInUseAuthorization()
            @unknown default:
                break
            }
        }
    }
}

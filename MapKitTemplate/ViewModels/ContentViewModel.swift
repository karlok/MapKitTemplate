//
//  ContentViewModel.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-25.
//

import SwiftUI
import MapKit
import Combine

struct ContentViewData {
    var cameraPosition: MapCameraPosition
    var isLoading: Bool
    var currentLocation: CLLocation?
}

@MainActor
class ContentViewModel: ObservableObject {
    @Published private(set) var viewData: ContentViewData

    private var locationManager: LocationManager
    private var errorManager: ErrorManager
    private var networkMonitor: NetworkMonitor
    private var cancellables = Set<AnyCancellable>()
    
    // Expose a binding for the camera position to allow for
    // two-way data flow between the view model and the map view
    // ensuring the UI and state remain in sync
    var cameraPositionBinding: Binding<MapCameraPosition> {
        Binding<MapCameraPosition>(
            get: { self.viewData.cameraPosition },
            set: { newPosition in
                self.updateViewData(cameraPosition: newPosition)
            }
        )
    }
    
    init(locationManager: LocationManager,
         errorManager: ErrorManager,
         networkMonitor: NetworkMonitor) {
        self.locationManager = locationManager
        self.errorManager = errorManager
        self.networkMonitor = networkMonitor
        
        self.viewData = ContentViewData(
            cameraPosition: .userLocation(
                fallback: .region(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            ),
            isLoading: false,
            currentLocation: nil
        )
        
        setupBindings()
    }
    
    private func setupBindings() {
        locationManager.$loadingState
            .sink { [weak self] state in
                self?.handleLoadingState(state)
            }
            .store(in: &cancellables)
    }
    
    private func handleLoadingState(_ state: MapLoadingState) {
        switch state {
        case .loading:
            updateViewData(isLoading: true)
        case .loaded:
            if let location = locationManager.currentLocation {
                updateViewData(currentLocation: location)
                updateCameraPosition(to: location.coordinate)
            }
            updateViewData(isLoading: false)
        case .failed(let error):
            errorManager.showError(error.localizedDescription)
            updateViewData(isLoading: false)
        default:
            break
        }
    }
    
    private func updateCameraPosition(to coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut) {
            updateViewData(
                cameraPosition: .region(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                    )
                )
            )
        }
    }
    
    private func updateViewData(
        cameraPosition: MapCameraPosition? = nil,
        isLoading: Bool? = nil,
        currentLocation: CLLocation? = nil
    ) {
        viewData = ContentViewData(
            cameraPosition: cameraPosition ?? viewData.cameraPosition,
            isLoading: isLoading ?? viewData.isLoading,
            currentLocation: currentLocation ?? viewData.currentLocation
        )
    }
}

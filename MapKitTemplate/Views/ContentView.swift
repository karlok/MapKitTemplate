//
//  ContentView.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel: ContentViewModel

    init(locationManager: LocationManager, errorManager: ErrorManager, networkMonitor: NetworkMonitor) {
        _viewModel = StateObject(
            wrappedValue: ContentViewModel(
                locationManager: locationManager,
                errorManager: errorManager,
                networkMonitor: networkMonitor
            )
        )
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: viewModel.cameraPositionBinding) {
                UserAnnotation()
            }
            .edgesIgnoringSafeArea(.all)
            
            UserLocationButton(cameraPosition: viewModel.cameraPositionBinding)
                .padding()
            
            if viewModel.viewData.isLoading {
                ProgressView("Loading map...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
            }
        }
    }
}

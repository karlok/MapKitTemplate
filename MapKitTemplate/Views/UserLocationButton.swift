//
//  UserLocationButton.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-26.
//

import SwiftUI
import MapKit

struct UserLocationButton: View {
    @EnvironmentObject var locationManager: LocationManager
    // This binding allows the button to update the camera position on the map.
    @Binding var cameraPosition: MapCameraPosition

    var body: some View {
        Button {
            if let currentLocation = locationManager.currentLocation {
                withAnimation(.easeInOut) {
                    cameraPosition = .region(
                        MKCoordinateRegion(
                            center: currentLocation.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                        )
                    )
                }
            }
        } label: {
            Image(systemName: "location.fill")
                .font(.title2)
                .padding(10)
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

//
//  RootView.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-24.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var errorManager: ErrorManager
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var networkMonitor: NetworkMonitor

    var body: some View {
        ZStack {
            // Pass the managers to ContentView so it can create its ViewModel
            ContentView(
                locationManager: locationManager,
                errorManager: errorManager,
                networkMonitor: networkMonitor
            )
            
            // display errors/network changes over any View in the app
            if let errorMessage = errorManager.errorMessage {
                ErrorView(message: errorMessage)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if !networkMonitor.isConnected {
                NetworkStatusView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear {
            withAnimation(.easeInOut) {
                locationManager.requestLocationAccess()
            }
        }
    }
}

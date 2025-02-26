//
//  MapKitTemplateApp.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-24.
//

import SwiftUI

struct AppConstants {
    static let errorDisplayDuration: UInt64 = 3 * 1_000_000_000
}

enum AppError: Error, LocalizedError {
    case locationAccessDenied
    case networkConnectionLost
    case custom(String)
    
    var errorDescription: String? {
        switch self {
        case .locationAccessDenied:
            return "Location access denied. Enable it in Settings."
        case .networkConnectionLost:
            return "Network connection lost."
        case .custom(let message):
            return message
        }
    }
}

@main
struct MapKitTemplateApp: App {
    @StateObject private var errorManager: ErrorManager
    @StateObject private var locationManager: LocationManager
    @StateObject private var networkMonitor: NetworkMonitor

    init() {
        let errorMgr = ErrorManager()
        _errorManager = StateObject(wrappedValue: errorMgr)
        let locManager = LocationManager(errorManager: errorMgr)
        _locationManager = StateObject(wrappedValue: locManager)
        let netMonitor = NetworkMonitor(errorManager: errorMgr)
        _networkMonitor = StateObject(wrappedValue: netMonitor)
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(errorManager)
                .environmentObject(locationManager)
                .environmentObject(networkMonitor)
        }
    }
}

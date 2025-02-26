//
//  NetworkMonitor.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-24.
//

import Foundation
import Network

@MainActor
class NetworkMonitor: ObservableObject {
    @Published var isConnected: Bool = true
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    private let errorManager: ErrorManager
    
    init(errorManager: ErrorManager) {
        self.errorManager = errorManager
        
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                let connected = path.status == .satisfied
                if self?.isConnected != connected {
                    self?.isConnected = connected
                    if !connected {
                        self?.errorManager.showError(AppError.networkConnectionLost.localizedDescription)
                    }
                }
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

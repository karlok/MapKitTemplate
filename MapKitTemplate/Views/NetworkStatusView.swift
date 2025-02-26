//
//  NetworkStatusView.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-24.
//

import SwiftUI

struct NetworkStatusView: View {
    @EnvironmentObject var networkMonitor: NetworkMonitor

    var body: some View {
        if !networkMonitor.isConnected {
            VStack {
                Text(AppError.networkConnectionLost.localizedDescription)
                    .padding()
                    .background(Color.yellow.opacity(0.8))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .padding()
                
                Spacer()
            }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

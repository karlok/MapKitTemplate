//
//  ErrorView.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-24.
//

import SwiftUI

struct ErrorView: View {
    let message: String

    var body: some View {
        VStack {
            Spacer()
            Text(message)
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

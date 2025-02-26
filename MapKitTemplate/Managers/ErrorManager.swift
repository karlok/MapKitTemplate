//
//  ErrorManager.swift
//  MapKitTemplate
//
//  Created by Karlo K on 2025-02-24.
//

import Foundation

@MainActor
class ErrorManager: ObservableObject {
    @Published var errorMessage: String?
    
    // hold a reference to the task responsible for clearing the error message
    // `clearErrorTask` ensures that the error message is displayed for a set duration and then automatically cleared—
    // unless a new error occurs before that time, in which case the previous task is canceled and replaced by a new one.
    private var clearErrorTask: Task<Void, Never>?

    func showError(_ message: String) {
        clearErrorTask?.cancel() // cancel any pending clear actions when a new error arrives
        errorMessage = message
        clearErrorTask = Task { // a new task is created and assigned to clearErrorTask
            try? await Task.sleep(nanoseconds: AppConstants.errorDisplayDuration)
            if !Task.isCancelled {
                self.errorMessage = nil
            }
        }
    }
}

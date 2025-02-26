//
//  MapKitTemplateTests.swift
//  MapKitTemplateTests
//
//  Created by Karlo K on 2025-02-24.
//

import XCTest
import CoreLocation
@testable import MapKitTemplate

@MainActor
final class MapKitTemplateTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShowErrorClearsAfterDelay() async throws {
        let errorManager = ErrorManager()
        // Show an error
        errorManager.showError("Test Error")
        
        // Immediately the error should be set
        XCTAssertEqual(errorManager.errorMessage, "Test Error")
        
        // Wait slightly longer than the delay duration (e.g., 3.1 seconds)
        try await Task.sleep(nanoseconds: 3_100_000_000)
        
        // After the delay, the error message should be nil
        XCTAssertNil(errorManager.errorMessage)
    }
    
    /**
        When showError is called, any existing clear task gets canceled.
        So, if error A is shown and then error B is shown, error A’s clear task is canceled.
        After waiting for the 3-second duration for error B, the test should verify error A never shows up and that error B clears at the correct time
     */
    func testShowErrorCalledMultipleTimesInRapidSuccession() async throws {
        let errorManager = ErrorManager()
        
        // Show the first error.
        errorManager.showError("Error A")
        // Verify immediately that "Error A" is displayed.
        XCTAssertEqual(errorManager.errorMessage, "Error A")
        
        // Wait 1 second (less than the total display duration, which is 3 seconds).
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Show the second error.
        errorManager.showError("Error B")
        // Verify immediately that the error message is now "Error B".
        XCTAssertEqual(errorManager.errorMessage, "Error B")
        
        // Wait for the remaining duration (roughly 2.1 seconds to be safely over the 3-second period).
        try await Task.sleep(nanoseconds: 3_100_000_000)
        
        // After the full display duration, the error message should be cleared.
        XCTAssertNil(errorManager.errorMessage)
    }
    
    func testContentViewModelUpdatesOnLoaded() async throws {
        // Create shared dependencies
        let errorManager = ErrorManager()
        let networkMonitor = NetworkMonitor(errorManager: errorManager)
        let locationManager = LocationManager(errorManager: errorManager)
        
        // Create the view model with these dependencies
        let viewModel = ContentViewModel(
            locationManager: locationManager,
            errorManager: errorManager,
            networkMonitor: networkMonitor
        )
        
        // Create a dummy location (e.g., New York City)
        let dummyLocation = CLLocation(latitude: 40.7128, longitude: -74.0060)
        
        // Simulate the location manager updating its state to .loaded with a new location.
        locationManager.currentLocation = dummyLocation
        locationManager.loadingState = .loaded
        
        // Wait briefly to allow the Combine pipeline to process the change.
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        
        // Verify that the view model has updated its state accordingly.
        XCTAssertFalse(viewModel.viewData.isLoading)
        XCTAssertNotNil(viewModel.viewData.currentLocation)
        let actualLatitude = try XCTUnwrap(viewModel.viewData.currentLocation?.coordinate.latitude)
        XCTAssertEqual(actualLatitude, dummyLocation.coordinate.latitude, accuracy: 0.0001)
        let actualLongitude = try XCTUnwrap(viewModel.viewData.currentLocation?.coordinate.longitude)
        XCTAssertEqual(actualLongitude, dummyLocation.coordinate.longitude, accuracy: 0.0001)
    }

}

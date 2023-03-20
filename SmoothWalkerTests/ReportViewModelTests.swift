//
//  ReportViewModelTests.swift
//  SmoothWalkerTests
//
//  Created by Kinshuk Juneja on 3/20/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import XCTest
import HealthKit
@testable import SmoothWalker

final class ReportViewModelTests: XCTestCase {
    
    class MockReportViewController: ReportViewInput {
        
        var refreshCallCount = 0
        
        func refresh() {
            refreshCallCount += 1
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewModelSetup() {
        let view = MockReportViewController()
        
        let reportViewModel = ReportViewModel(view: view, dataTypeIdentifier: HKQuantityTypeIdentifier.walkingSpeed.rawValue)
        
        XCTAssertEqual(reportViewModel.title, "🚶🏼‍♀️Avg Walking Speed")
    }
    
    func testSelectedDateRange() {
        let view = MockReportViewController()
        
        let reportViewModel = ReportViewModel(view: view, dataTypeIdentifier: HKQuantityTypeIdentifier.walkingSpeed.rawValue)
        
        // Test default date range selection
        XCTAssertEqual(reportViewModel.selectedDateRange, DateRange.week)

        // We can test change in selectedDateRange by refactoring ChartTableViewController to be protocol based.
    }
    
    // dataValues, chartValues, and loadData can all be tested by moving performQuery to a reportDataService and having the service confirm to a protocol. That way we can mock the service and use the data to test dataValues, chartValues, and loadData.
}

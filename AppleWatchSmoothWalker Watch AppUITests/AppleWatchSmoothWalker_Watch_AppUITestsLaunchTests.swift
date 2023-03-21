//
//  AppleWatchSmoothWalker_Watch_AppUITestsLaunchTests.swift
//  AppleWatchSmoothWalker Watch AppUITests
//
//  Created by Kinshuk Juneja on 3/20/23.
//  Copyright © 2023 Apple. All rights reserved.
//

import XCTest

final class AppleWatchSmoothWalker_Watch_AppUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testLaunch() throws {
        let app = XCUIApplication()
        app.launch()

        // Insert steps here to perform after app launch but before taking a screenshot,
        // such as logging into a test account or navigating somewhere in the app

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

//
//  GamesLibraryUITests.swift
//  GamesLibraryUITests
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import XCTest

final class GamesLibraryUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func givenAppWhenLaunchedThenExampleWorks() throws {
        // given
        let app = XCUIApplication()

        // when
        app.launch()

        // then
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func givenAppWhenLaunchIsMeasuredThenPerformanceIsTracked() throws {
        // given
        let metrics = [XCTApplicationLaunchMetric()]

        // when
        measure(metrics: metrics) {
            XCUIApplication().launch()
        }

        // then
        // Performance is measured by XCTest
    }
}

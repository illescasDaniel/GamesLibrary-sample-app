//
//  GamesLibraryUITestsLaunchTests.swift
//  GamesLibraryUITests
//
//  Created by Daniel Illescas Romero on 6/5/26.
//

import XCTest

final class GamesLibraryUITestsLaunchTests: XCTestCase {

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func givenAppWhenLaunchedThenScreenshotIsTaken() throws {
        // given
        let app = XCUIApplication()

        // when
        app.launch()

        // then
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

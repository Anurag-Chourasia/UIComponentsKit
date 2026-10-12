import XCTest
final class InteractionTests: XCTestCase {
    @MainActor func testNativeActionsDisabledStateAndCardInteraction() {
        let app = XCUIApplication()
        app.launch()
        let increment = app.buttons["increment"]
        XCTAssertTrue(increment.waitForExistence(timeout: 10))
        XCTAssertGreaterThanOrEqual(increment.frame.height, 44)
        XCTAssertGreaterThanOrEqual(increment.frame.width, 44)
        increment.tap()
        XCTAssertEqual(app.staticTexts["count"].label, "Count 1")
        XCTAssertFalse(app.buttons["disabled"].isEnabled)
        app.buttons["disabled"].tap()
        XCTAssertEqual(app.staticTexts["count"].label, "Count 1")
        app.buttons["inside"].tap()
        XCTAssertEqual(app.staticTexts["count"].label, "Count 2")
        XCTAssertTrue(app.staticTexts["caption"].exists)
    }
    @MainActor func testPresentationActionsFieldBindingAndNativeProgress() {
        let app = XCUIApplication()
        app.launchArguments = ["presentation"]
        app.launch()
        XCTAssertTrue(app.buttons["retry"].waitForExistence(timeout: 10))
        app.buttons["retry"].tap()
        XCTAssertEqual(app.staticTexts["count"].label, "Count 1")
        let outlined = app.buttons["outlined"]
        XCTAssertEqual(outlined.label, "Go back")
        XCTAssertGreaterThanOrEqual(outlined.frame.height, 44)
        outlined.tap()
        XCTAssertEqual(app.staticTexts["count"].label, "Count 2")
        XCTAssertTrue(app.staticTexts["Offline notice"].exists)
        // Indeterminate ProgressView exposes ActivityIndicator on iOS.
        // Verify both the reference and extracted compositions retain native spinners.
        for label in ["Reference loading", "Loading fixture"] {
            let progress = app.activityIndicators[label]
            XCTAssertTrue(progress.exists)
            XCTAssertEqual(progress.value as? String, "1")
        }
        XCTAssertTrue(app.staticTexts["Loading fixture"].exists)
        XCTAssertTrue(app.staticTexts["Reference loading"].exists)
        let field = app.textFields["field"]
        field.tap()
        field.typeText("fixture")
        XCTAssertEqual(field.value as? String, "fixture")
    }
}

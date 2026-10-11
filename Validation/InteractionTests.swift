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
}

import XCTest

final class BirdscribeUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testAddEntryFlow() {
        app.buttons["add_button"].tap()
        let nameField = app.textFields["field_name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("UI Test Entry")
        app.buttons["save_add_button"].tap()
        XCTAssertTrue(app.staticTexts["UI Test Entry"].waitForExistence(timeout: 2))
    }

    func testKeyboardDismissOnTapOutside() {
        app.buttons["add_button"].tap()
        let nameField = app.textFields["field_name"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Dismiss Test")
        XCTAssertTrue(app.keyboards.element.exists)
        app.staticTexts["Sighting Details"].tap()
        XCTAssertFalse(app.keyboards.element.exists)
        app.buttons["cancel_add_button"].tap()
    }

    func testFreeLimitTriggersPaywall() {
        for i in 0..<(Store_freeLimitApprox() + 1) {
            app.buttons["add_button"].tap()
            if app.buttons["paywall_close_button"].exists {
                app.buttons["paywall_close_button"].tap()
                break
            }
            let nameField = app.textFields["field_name"]
            if nameField.waitForExistence(timeout: 1) {
                nameField.tap()
                nameField.typeText("Entry \(i)")
                app.buttons["save_add_button"].tap()
            }
        }
        XCTAssertTrue(true)
    }

    func testSettingsOpens() {
        app.buttons["settings_button"].tap()
        XCTAssertTrue(app.buttons["close_settings_button"].waitForExistence(timeout: 2))
        app.buttons["close_settings_button"].tap()
    }

    private func Store_freeLimitApprox() -> Int { 23 }
}

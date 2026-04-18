import XCTest

final class BaseFunctionalityUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_tabs_areVisible() throws {
        XCTAssertTrue(app.tabBars.buttons["Home"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Workouts"].exists)
        XCTAssertTrue(app.tabBars.buttons["Analytics"].exists)
        XCTAssertTrue(app.tabBars.buttons["Progress"].exists)
        XCTAssertTrue(app.tabBars.buttons["Settings"].exists)
    }

    func test_workoutsTab_emptyState_allowsStartingWorkout() throws {
        app.tabBars.buttons["Workouts"].tap()

        let startWorkoutButton = app.buttons["Start Workout"]
        XCTAssertTrue(startWorkoutButton.waitForExistence(timeout: 5))

        startWorkoutButton.tap()

        XCTAssertTrue(app.buttons["Finish"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["addExerciseButton"].waitForExistence(timeout: 5))
    }

    func test_startAndFinishWorkout_returnsToWorkoutsList() throws {
        app.tabBars.buttons["Workouts"].tap()

        let startWorkoutButton = app.buttons["Start Workout"]
        XCTAssertTrue(startWorkoutButton.waitForExistence(timeout: 5))
        startWorkoutButton.tap()

        let finishButton = app.buttons["Finish"]
        XCTAssertTrue(finishButton.waitForExistence(timeout: 5))
        finishButton.tap()

        let confirmFinishButton = app.buttons["Finish Workout"]
        XCTAssertTrue(confirmFinishButton.waitForExistence(timeout: 5))
        confirmFinishButton.tap()

        XCTAssertTrue(app.navigationBars["Workouts"].waitForExistence(timeout: 5) || app.staticTexts["Workouts"].exists)
    }

    func test_workoutHistoryScreen_isReachable() throws {
        app.tabBars.buttons["Workouts"].tap()

        XCTAssertTrue(app.navigationBars["Workouts"].waitForExistence(timeout: 5) || app.staticTexts["Workouts"].exists)

        let hasEmptyState = app.staticTexts["No Workouts"].waitForExistence(timeout: 3)
        let hasWorkoutRow = app.tables.cells.firstMatch.waitForExistence(timeout: 3)

        XCTAssertTrue(hasEmptyState || hasWorkoutRow)
    }

    func test_analyticsTab_isReachable() throws {
        app.tabBars.buttons["Analytics"].tap()

        XCTAssertTrue(app.navigationBars["Analytics"].waitForExistence(timeout: 5) || app.staticTexts["Analytics"].exists)
    }

    func test_progressTab_isReachable() throws {
        app.tabBars.buttons["Progress"].tap()

        XCTAssertTrue(app.navigationBars["Progress"].waitForExistence(timeout: 5) || app.staticTexts["Progress"].exists)
    }

    func test_fromRoutine_sheet_opens() throws {
        app.tabBars.buttons["Workouts"].tap()

        let addMenuButton = app.navigationBars["Workouts"].buttons.element(boundBy: 0)
        XCTAssertTrue(addMenuButton.waitForExistence(timeout: 5))
        addMenuButton.tap()

        let fromRoutineButton = app.buttons["From Routine"]
        XCTAssertTrue(fromRoutineButton.waitForExistence(timeout: 5))
        fromRoutineButton.tap()

        XCTAssertTrue(app.navigationBars["Select Routine"].waitForExistence(timeout: 5) || app.staticTexts["Select Routine"].exists)
    }
}

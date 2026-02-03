import XCTest

final class ExerciseSelectionUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Exercise Selection Tests
    
    func test_exerciseSelection_displaysExerciseList() throws {
        // Navigate to Workouts tab
        app.tabBars.buttons["Workouts"].tap()
        
        // Start a new workout
        app.buttons["Start Workout"].tap()
        
        // Tap "Add Exercise" button
        let addExerciseButton = app.buttons["addExerciseButton"]
        XCTAssertTrue(addExerciseButton.waitForExistence(timeout: 5))
        addExerciseButton.tap()
        
        // Verify exercise list appears
        let exerciseList = app.scrollViews["exerciseList"]
        XCTAssertTrue(exerciseList.waitForExistence(timeout: 5))
        
        // Verify search field exists
        let searchField = app.textFields["exerciseSearchField"]
        XCTAssertTrue(searchField.exists)
        
        // Verify muscle group filter exists
        let muscleGroupFilter = app.scrollViews["muscleGroupFilter"]
        XCTAssertTrue(muscleGroupFilter.exists)
    }
    
    func test_exerciseSelection_searchFiltersResults() throws {
        // Navigate to exercise selection
        navigateToExerciseSelection()
        
        // Type in search field
        let searchField = app.textFields["exerciseSearchField"]
        searchField.tap()
        searchField.typeText("Bench")
        
        // Wait for filtering
        sleep(1)
        
        // Verify filtered results contain "Bench"
        let exerciseList = app.scrollViews["exerciseList"]
        XCTAssertTrue(exerciseList.exists)
        
        // Check that Bench Press exercise appears
        let benchPressRow = app.cells.containing(.staticText, identifier: "Barbell Bench Press").element
        XCTAssertTrue(benchPressRow.exists || app.staticTexts["Barbell Bench Press"].exists)
    }
    
    func test_exerciseSelection_selectExerciseAddsToWorkout() throws {
        // Navigate to exercise selection
        navigateToExerciseSelection()
        
        // Find and tap on an exercise
        let benchPressText = app.staticTexts["Barbell Bench Press"]
        if benchPressText.waitForExistence(timeout: 5) {
            benchPressText.tap()
        }
        
        // Verify we're back to active workout
        let finishButton = app.buttons["Finish"]
        XCTAssertTrue(finishButton.waitForExistence(timeout: 5))
        
        // Verify exercise was added (check for Set 1 or exercise name)
        let exerciseAdded = app.staticTexts["Barbell Bench Press"].exists ||
                           app.staticTexts["Set 1"].exists
        XCTAssertTrue(exerciseAdded)
    }
    
    func test_exerciseSelection_cancelDismissesSheet() throws {
        // Navigate to exercise selection
        navigateToExerciseSelection()
        
        // Tap cancel button
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 5))
        cancelButton.tap()
        
        // Verify we're back to active workout (exercise selection is dismissed)
        let addExerciseButton = app.buttons["addExerciseButton"]
        XCTAssertTrue(addExerciseButton.waitForExistence(timeout: 5))
    }
    
    // MARK: - Helpers
    
    private func navigateToExerciseSelection() {
        // Navigate to Workouts tab
        app.tabBars.buttons["Workouts"].tap()
        
        // Start a new workout
        let startButton = app.buttons["Start Workout"]
        if startButton.waitForExistence(timeout: 5) {
            startButton.tap()
        }
        
        // Tap "Add Exercise" button
        let addExerciseButton = app.buttons["addExerciseButton"]
        if addExerciseButton.waitForExistence(timeout: 5) {
            addExerciseButton.tap()
        }
        
        // Wait for exercise list to appear
        _ = app.scrollViews["exerciseList"].waitForExistence(timeout: 5)
    }
}

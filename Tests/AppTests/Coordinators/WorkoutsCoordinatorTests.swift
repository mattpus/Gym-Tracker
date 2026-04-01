import XCTest
@testable import Gym_Tracker

@MainActor
final class WorkoutsCoordinatorTests: XCTestCase {
    func test_showWorkoutDetail_appendsRouteToPath() {
        let sut = makeSUT()
        let workoutID = UUID()
        
        sut.showWorkoutDetail(workoutId: workoutID)
        
        XCTAssertEqual(sut.path, [.workoutDetail(id: workoutID)])
    }
    
    func test_showRoutineSelection_setsRoutineSheet() {
        let sut = makeSUT()
        
        sut.showRoutineSelection()
        
        XCTAssertEqual(sut.sheet, .routineSelection)
    }
    
    func test_showExerciseSelection_setsExerciseSheet_andCreatesViewModel() {
        let sut = makeSUT()
        
        sut.showExerciseSelection()
        
        XCTAssertEqual(sut.sheet, .exerciseSelection)
        XCTAssertNotNil(sut.exerciseSelectionViewModel)
    }
    
    func test_dismissExerciseSelection_clearsSheet_andViewModel() {
        let sut = makeSUT()
        sut.showExerciseSelection()
        
        sut.dismissExerciseSelection()
        
        XCTAssertNil(sut.sheet)
        XCTAssertNil(sut.exerciseSelectionViewModel)
    }
    
    private func makeSUT() -> WorkoutsCoordinator {
        let container = DependencyContainer()
        let coordinator = WorkoutsCoordinator(container: container)
        coordinator.start()
        return coordinator
    }
}

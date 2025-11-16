import XCTest
@testable import WorkoutsDomain

final class RoutineReorderingUseCaseTests: XCTestCase {
	
	func test_reorderExercises_withInvalidIndexes_fails() {
		let sut = RoutineReorderingUseCase()
		let routine = makeRoutine()
		
		switch sut.reorderExercises(in: routine, from: 5, to: 0) {
		case let .failure(error as RoutineReorderingUseCase.Error):
			XCTAssertEqual(error, .invalidIndexes)
		default:
			XCTFail("Expected invalidIndexes error")
		}
	}
	
	func test_reorderExercises_movesExercise() {
		let sut = RoutineReorderingUseCase()
		let routine = makeRoutine()
		
		let result = try? sut.reorderExercises(in: routine, from: 0, to: 1).get()
		
		XCTAssertEqual(result?.exercises.first?.name, "Deadlift")
		XCTAssertEqual(result?.exercises.last?.name, "Bench")
	}
	
	// MARK: - Helpers
	
	private func makeRoutine() -> Routine {
		let bench = RoutineExercise(name: "Bench", sets: [RoutineSet(order: 0)])
		let deadlift = RoutineExercise(name: "Deadlift", sets: [RoutineSet(order: 0)])
		return Routine(name: "Push", exercises: [bench, deadlift])
	}
}

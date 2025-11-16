import XCTest
@testable import WorkoutsDomain

final class ExerciseTests: XCTestCase {
	func test_init_setsAllProperties() {
		let id = UUID()
		let sets = [
			ExerciseSet(order: 0),
			ExerciseSet(order: 1)
		]
		let sut = Exercise(
			id: id,
			name: "Bench Press",
			notes: "Warm up",
			sets: sets
		)
		
		XCTAssertEqual(sut.id, id)
		XCTAssertEqual(sut.name, "Bench Press")
		XCTAssertEqual(sut.notes, "Warm up")
		XCTAssertEqual(sut.sets, sets)
	}
	
	func test_isCompleted_reflectsPresenceOfSets() {
		XCTAssertFalse(Exercise(name: "Bench Press", sets: []).isCompleted)
		XCTAssertTrue(Exercise(name: "Bench Press", sets: [ExerciseSet(order: 0)]).isCompleted)
	}
}

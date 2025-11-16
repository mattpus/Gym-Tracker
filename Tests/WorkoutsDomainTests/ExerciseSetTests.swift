import XCTest
@testable import WorkoutsDomain

final class ExerciseSetTests: XCTestCase {
	func test_init_setsAllProperties() {
		let id = UUID()
		let sut = ExerciseSet(
			id: id,
			order: 1,
			repetitions: 10,
			weight: 42.5,
			duration: 60
		)
		
		XCTAssertEqual(sut.id, id)
		XCTAssertEqual(sut.order, 1)
		XCTAssertEqual(sut.repetitions, 10)
		XCTAssertEqual(sut.weight, 42.5)
		XCTAssertEqual(sut.duration, 60)
	}
	
	func test_isTimedSet_reflectsDurationPresence() {
		XCTAssertTrue(ExerciseSet(order: 0, duration: 30).isTimedSet)
		XCTAssertFalse(ExerciseSet(order: 0).isTimedSet)
	}
	
	func test_isWeightedSet_reflectsWeightPresence() {
		XCTAssertTrue(ExerciseSet(order: 0, weight: 5).isWeightedSet)
		XCTAssertFalse(ExerciseSet(order: 0).isWeightedSet)
	}
}
